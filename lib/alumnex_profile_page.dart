import 'dart:convert';
import 'dart:io';
import 'package:alumnex/alumn_global.dart';
import 'package:alumnex/alumnex_database_connection_page.dart';
import 'package:alumnex/alumnex_global_chat_page.dart';
import 'package:alumnex/alumnex_leaderboard_page.dart';
import 'package:alumnex/alumnex_login_page.dart';
import 'package:alumnex/alumnex_mentor_request_page.dart';
import 'package:alumnex/alumnex_post_upload_page.dart';
import 'package:alumnex/alumnex_resume_page.dart';
import 'package:alumnex/alumnex_sideSheets_profile.dart';
import 'package:alumnex/alumnex_view_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 📸 ADD this


class AlumnexProfilePage extends StatefulWidget {
  final String rollno;

  final dynamic roll;
  const AlumnexProfilePage({
    super.key,
    required this.rollno,
    required this.roll,
  });

  @override
  State<AlumnexProfilePage> createState() => _AlumnexProfilePageState();
}

class _AlumnexProfilePageState extends State<AlumnexProfilePage> {
  File? _profileImage;
  File? _profileResume; // 📸 Store selected image

  @override
  void initState() {
    super.initState();
    fetchData(widget.rollno);
  }

  void fetchData(String rollNo) async {
    final response = await DataBaseConnection().GetPersonInfo({
      "rollno": rollNo,
    });
    if (response != null && response.statusCode == 200) {
      setState(() {
        person = jsonDecode(response.body);
      });
    } else {
      print("Failed to get data");
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path); // just set the UI
      });

      // After UI updated, call upload separately
      final res = await DataBaseConnection().uploadProfileImage(
        _profileImage!,
        person["_id"],
      );

      print(res as String);
    }
  }
Future<void> _pickResume() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    _profileResume = File(pickedFile.path);
    String result = await DataBaseConnection().uploadResume(_profileResume!, person["_id"]);
    print(result);
  }
}



  void _editProfileField(String key) {
    TextEditingController titleController = TextEditingController(
      text: person[key]![0],
    );
    TextEditingController subtitleController = TextEditingController(
      text: person[key]![1],
    );
    TextEditingController urlController = TextEditingController(
      text: person[key]![2],
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Edit Profile Field"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: "Title"),
                ),
                TextField(
                  controller: subtitleController,
                  decoration: InputDecoration(labelText: "Subtitle"),
                ),
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(labelText: "URL"),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    person[key] = [
                      titleController.text,
                      subtitleController.text,
                      urlController.text,
                    ];
                    if (200 ==
                        DataBaseConnection().updatepersonalinfo(person)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('profile updated successfully')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('problem in profile updation')),
                      );
                    }
                  });
                  Navigator.pop(context);
                },
                child: Text("Save"),
              ),
            ],
          ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchMentoredStudents() async {
    List<Map<String, dynamic>> studentDetails = [];
    if (person["mentoring"] != null && person["mentoring"] is List) {
      for (var studentId in person["mentoring"]) {
        var student = await DataBaseConnection().GetPersonInfo({
          'rollno': studentId,
        }); // assuming it returns Map<String, dynamic>
        if (student != null) {
          studentDetails.add(jsonDecode(student.body));
        }
      }
    }
    return studentDetails;
  }

  void _addNewProfileField() {
    TextEditingController titleController = TextEditingController();
    TextEditingController subtitleController = TextEditingController();
    TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Add New Profile Field"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: "Title"),
                ),
                TextField(
                  controller: subtitleController,
                  decoration: InputDecoration(labelText: "Subtitle"),
                ),
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(labelText: "URL"),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    person["key${person.length + 1}"] = [
                      titleController.text,
                      subtitleController.text,
                      urlController.text,
                    ];
                    if (200 ==
                        DataBaseConnection().updatepersonalinfo(person)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('profile Added successfully')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('problem in Adding the profile'),
                        ),
                      );
                    }
                  });
                  Navigator.pop(context);
                },
                child: Text("Add"),
              ),
            ],
          ),
    );
  }

  bool _isMenuOpen = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => AlumnexMentorRequestPage(rollno: widget.rollno),
                ),
              );
            },
            icon: Icon(Icons.notifications_none),
          ),
          IconButton(onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AlumnexLeaderboardPage()),
              );
          }, icon: Icon(Icons.golf_course_sharp)),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => AlumnexLoginPage()),
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(width: double.infinity),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => Align(
                          alignment: Alignment.centerLeft,
                          child: Material(
                            child: Container(
                              width: 300,
                              height: MediaQuery.of(context).size.height,
                              color: Colors.white,
                              child: AlumnexSidesheetsProfile(
                                roll: widget.roll,
                              ),
                            ),
                          ),
                        ),
                  );
                },
                icon: Icon(Icons.menu),
              ),
            ),
            SizedBox(height: 20),
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  radius: 80,
                  child: ClipOval(
                    child:
                        _profileImage != null
                            ? Image.file(
                              _profileImage!,
                              width: 160,
                              height: 160,
                              fit: BoxFit.cover,
                            )
                            : Image.network(
                              'http://192.168.157.76:5000/get-profile/${person["_id"]}', // Replace IP
                              width: 160,
                              height: 160,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.white,
                                );
                              },
                            ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Color(0xFF224146),
                    radius: 23,
                    child: IconButton(
                      icon: Icon(Icons.edit, color: Colors.orange),
                      onPressed: _pickImage,
                    ),
                  ),
                ),
              ],
            ),

            Text(
              person['_id'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '${person['programbranch']} (${person['Batch']})',
              style: TextStyle(fontSize: 18),
            ),

           ListTile(
  leading: Icon(Icons.link),
  title: Text("Resume"),
  subtitle: Text("View my profile"),
  trailing: IconButton(
    icon: Icon(Icons.edit, color: Colors.orange),
    onPressed: _pickResume,
  ),
  onTap: () {
    Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => AlumnexResumePage(rollno: person["_id"],),
                                  ),
                                );
    
  },
),


            // 🔥 Show Profile Data Dynamically
            ...person.entries.map((entry) {
              if (entry.key.startsWith("key")) {
                return ListTile(
                  leading: Icon(Icons.link),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _editProfileField(entry.key);
                    },
                  ),
                  title: Text(entry.value[0]),
                  subtitle: Text(entry.value[1]),
                  onTap: () {
                    // your tap action here
                  },
                );
              } else {
                return SizedBox(); // or return null, but SizedBox() is safe visually
              }
            }).toList(),

            ElevatedButton.icon(
              onPressed: _addNewProfileField,
              icon: Icon(Icons.add),
              label: Text("Add New Field"),
            ),

            SizedBox(height: 20),
            if (widget.roll == "Alumni") ...[
              Text("Mentoring for : ", style: TextStyle(fontSize: 18)),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchMentoredStudents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Error fetching students: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("No mentored students.");
                  }

                  final students = snapshot.data!;
                  return Column(
                    children:
                        students.map((student) {
                          return ListTile(
                            leading: CircleAvatar(radius: 30,
                            backgroundImage: NetworkImage(
                              "http://192.168.157.76:5000/get-profile/${student["_id"]}",
                            ),
                            backgroundColor: Colors.white,
                            ),
                            title: Text(student["_id"] ?? "No Name"),
                            subtitle: Text(
                              "${student["programbranch"] ?? ""} - Batch ${student["Batch"] ?? ""}",
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => AlumnexViewProfilePage(
                                          temprollno: student['_id'],
                                          temproll: student['roll'],
                                          rollno: widget.rollno,
                                          roll: widget.roll,
                                        
                                        ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.keyboard_double_arrow_right,
                              ),
                            ),
                          );
                        }).toList(),
                  );
                },
              ),
            ],
            if(widget.roll == 'Student')...[
  Text("Mentored By : ${person['mentoredby']}",style: TextStyle(fontSize: 18),)

],
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          if (_isMenuOpen) ...[
            Positioned(
              bottom: 120,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: primaryColor,
                heroTag: 'post',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              AlumnexPostUploadPage(rollno: person["_id"]),
                    ),
                  );
                },
                child: Icon(Icons.post_add, color: Colors.white),
              ),
            ),
            Positioned(
              bottom: 200,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: primaryColor,
                heroTag: 'const',
                onPressed: () {},

                child: Icon(Icons.content_paste_search, color: Colors.white),
              ),
            ),
            Positioned(
              bottom: 280,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: primaryColor,
                heroTag: 'questions',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                             AlumnexGlobalChatPage(rollno: widget.rollno,),
                    ),
                  );
                },
                child: Icon(Icons.question_answer, color: Colors.white),
              ),
            ),
          ],
          Positioned(
            bottom: 40,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: accentColor,
              onPressed: () {
                setState(() {
                  _isMenuOpen = !_isMenuOpen;
                });
              },
              child: Icon(_isMenuOpen ? Icons.close : Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
