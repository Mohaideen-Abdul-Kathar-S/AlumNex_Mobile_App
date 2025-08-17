import 'dart:convert';
// import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:alumnex/alumn_global.dart';
import 'package:alumnex/alumnex_database_connection_page.dart';
import 'package:alumnex/alumnex_global_chat_page.dart';
import 'package:alumnex/alumnex_individual_chat_screen.dart';
import 'package:alumnex/alumnex_leaderboard_page.dart';
import 'package:alumnex/alumnex_login_page.dart';
import 'package:alumnex/alumnex_mentor_request_page.dart';
import 'package:alumnex/alumnex_post_upload_page.dart';
import 'package:alumnex/alumnex_resume_page.dart';
import 'package:alumnex/alumnex_saved_posts_page.dart';
import 'package:alumnex/alumnex_sideSheets_profile.dart';
import 'package:alumnex/alumnex_tab_meet_page.dart';
import 'package:alumnex/alumnex_view_profile_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class AlumnexProfilePage extends StatefulWidget {
  final String rollno;

  final String roll;
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
  // 📸 Store selected image
  dynamic alumni = {"name": "name"};
  dynamic pesronFields = {"name": "name"};
  // final profileData = 5;
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
        pesronFields = person["fields"] ?? {};
      });
      print("on prfile checking " + pesronFields.toString());
      if (person["roll"] == "Student" && person["mentoredby"] != "Nill") {
        final a = await DataBaseConnection().GetPersonInfo({
          "rollno": person["mentoredby"],
        });
        if (a != null && a.statusCode == 200) {
          setState(() {
            alumni = jsonDecode(a.body);
          });

          print("alumni data on profile page"+alumni.toString());
        } else {
          alumni = {"name": "No Alumni Mentored"};
        }
      }
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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String res = await DataBaseConnection().uploadResume(file, person["_id"]);
      print(res);
    }
  }

  // Future<void> _pickResume() async {
  //   // Allow multiple file types
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['pdf', 'docx', 'doc', 'jpg', 'jpeg', 'png'],
  //   );

  //   if (result != null && result.files.single.path != null) {
  //     File file = File(result.files.single.path!);

  //     _profileResume = file;
  //     String response = await DataBaseConnection()
  //         .uploadResume(_profileResume!, person["_id"]);

  //     print(response);
  //   } else {
  //     print("No file selected");
  //   }
  // }

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
                      (context) =>
                          AlumnexMentorRequestPage(rollno: widget.rollno),
                ),
              );
            },
            icon: Icon(Icons.notifications_none), //
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => AlumnexSavedPostsPage(
                        rollno: widget.rollno,
                        roll: widget.roll,
                      ),
                ),
              );
            },
            icon: Icon(Icons.bookmark),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => AlumnexLeaderboardPage(
                        rollno: widget.rollno,
                        roll: widget.roll,
                      ),
                ),
              );
            },
            icon: Icon(Icons.golf_course_sharp),
          ),
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
      body: person?["_id"] != null
    ? SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(width: double.infinity),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () {
                  print("person sidesheet" + person.toString());
                  if (person?["fields"] != null) {
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
                  } else {
                    // optional: show a snackbar if fields are null
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("No profile data available")),
                    );
                  }
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
    : (person?["_id"] != null
        ? Image.network(
            'http://10.149.248.153:5000/get-profile/${person!["_id"]}',
            width: 160,
            height: 160,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.person, size: 80, color: Colors.white);
            },
          )
        : const Icon(Icons.person, size: 80, color: Colors.white))

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
              '${person?['fields']?['Program Branch'] ?? ""} '
              '${person?['fields']?['Batch'] ?? ""}',
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
                        (context) => AlumnexResumePage(rollno: person["_id"]),
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
                  onTap: () async {
                    // your link

                    AlumnexTabMeetPage(
                      rollno: widget.rollno,
                    ).launchURL(entry.value[2]);
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
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                "http://10.149.248.153:5000/get-profile/${student["_id"]}",
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
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) => AlumnexIndividualChatScreen(
                                        sender: widget.rollno,
                                        roll: widget.rollno,
                                        reciever: student['_id'],
                                      ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                  );
                },
              ),
            ],
            if (widget.roll == 'Student') ...[
              Text(
                "Mentored By : ${person['mentoredby'] == "Nill" ? "No Alumni Mentored" : person['mentoredby']}",
                style: TextStyle(fontSize: 18),
              ),
              if (person['mentoredby'] != "Nill") ...[
                ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      "http://10.149.248.153:5000/get-profile/${alumni['_id']}",
                    ),
                    backgroundColor: Colors.white,
                  ),
                  title: Text(alumni['_id'] ?? "No Name"),
                  subtitle: Text(
                    "${alumni["programbranch"] ?? ""} - Batch ${alumni["Batch"] ?? ""}",
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AlumnexViewProfilePage(
                                temprollno: alumni['_id'],
                                temproll: alumni['roll'],
                                rollno: widget.rollno,
                                roll: widget.roll,
                              ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.keyboard_double_arrow_right),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => AlumnexIndividualChatScreen(
                              sender: widget.rollno,
                              roll: widget.rollno,
                              reciever: alumni['_id'],
                            ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ],
        ),
      ):const Center(
        child: CircularProgressIndicator(),  // ✅ Spinner instead of text
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
                          (context) => AlumnexPostUploadPage(
                            rollno: person["_id"],
                            roll: widget.roll,
                          ),
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
                              AlumnexGlobalChatPage(rollno: widget.rollno),
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
