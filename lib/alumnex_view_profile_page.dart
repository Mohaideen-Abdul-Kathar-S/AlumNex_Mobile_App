import 'dart:convert';
import 'dart:io';
import 'package:alumnex/alumn_global.dart';
import 'package:alumnex/alumnex_database_connection_page.dart';

import 'package:alumnex/alumnex_view_sideSheets_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AlumnexViewProfilePage extends StatefulWidget {
  final String temprollno;

  final dynamic temproll;

  final dynamic rollno;

  final dynamic roll;
  const AlumnexViewProfilePage({
    super.key,
    required this.temprollno,
    required this.temproll,
    required this.rollno,
    required this.roll,
  });

  @override
  State<AlumnexViewProfilePage> createState() => _AlumnexViewProfilePageState();
}

class _AlumnexViewProfilePageState extends State<AlumnexViewProfilePage> {
  File? _tempprofileImage; // 📸 Store selected image
  int conn = 0; // Default value

  @override
  void initState() {
    super.initState();
    fetchconn().then((value) {
      setState(() {
        conn = value;
      });
    });
    fetchData(widget.temprollno);
  }

  Future<int> fetchconn() async {
    final response = await http.get(
      Uri.parse(
        "http://192.168.157.76:5000/check_connection/${widget.rollno}/${widget.temprollno}",
      ),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Assuming the API returns plain int
    } else {
      return 0;
    }
  }

  void fetchData(String temprollNo) async {
    final response = await DataBaseConnection().GetPersonInfo({
      "rollno": temprollNo,
    });
    if (response != null && response.statusCode == 200) {
      setState(() {
        person = jsonDecode(response.body);
      });
    } else {
      print("Failed to get data");
    }
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

  bool _isMenuOpen = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),

            child: ElevatedButton(
              onPressed: () async {
                final res = await DataBaseConnection().Connect_with_frd(
                  widget.rollno,
                  widget.temprollno,
                );
                if (res == 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Connection maded")),
                  );
                  setState(() {
                    conn = 1;
                  }); 
                } else if (res == 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Connection breaked")),
                  );
                  setState(() {
                    conn = 0;
                  }); 
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("error in connection")),
                  );
                }
              },
              child:
                  conn == 1
                      ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.remove, color: Colors.red),
                          SizedBox(width: 5),
                          Text(
                            "Disconnect",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      )
                      : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.green),
                          SizedBox(width: 5),
                          Text(
                            "Connect",
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
            ),
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
                              child: AlumnexViewSidesheetsPage(
                                roll: widget.temproll,
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
                        _tempprofileImage != null
                            ? Image.file(
                              _tempprofileImage!,
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
              ],
            ),

            Text(
              person['_id'], //person['name']
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '${person['programbranch']} (${person['Batch']})',
              style: TextStyle(fontSize: 18),
            ),

            // 🔥 Show Profile Data Dynamically
            ...person.entries.map((entry) {
              if (entry.key.startsWith("key")) {
                return ListTile(
                  leading: Icon(Icons.link),
                  trailing: IconButton(
                    icon: Icon(Icons.keyboard_double_arrow_right),
                    onPressed: () {},
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

            SizedBox(height: 20),
            if (widget.temproll == "Alumni") ...[
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
                                          roll: widget,
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
            if (widget.temproll == 'Student') ...[
              Text(
                "Mentored By : ${person['mentoredby']}, ${person["connections"]},${widget.rollno}",
                style: TextStyle(fontSize: 18),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          if (_isMenuOpen) ...[
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
                  print('Questions clicked');
                },
                child: Icon(Icons.question_answer, color: Colors.white),
              ),
            ),
            if (widget.roll != widget.temproll) ...[
              Positioned(
                bottom: 120,
                right: 16,
                child: FloatingActionButton(
                  backgroundColor: primaryColor,
                  heroTag: 'Request',
                  onPressed: () async {
                    String sender =
                        widget.rollno; // assuming this is the current user's ID
                    String receiver =
                        widget.temprollno; // the profile being viewed

                    String type = '';
                    if (widget.roll == "Alumni" &&
                        (person['mentoredby'] == null ||
                            person['mentoredby'] == 'Nill')) {
                      type = "mentorship_request_by_alumni";
                    } else {
                      type = "mentorship_request_by_student";
                    }

                    final response = await http.post(
                      Uri.parse("http://192.168.157.76:5000/sendRequest"),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        "from": sender,
                        "to": receiver,
                        "type": type,
                      }),
                    );

                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Request sent')));
                    } else {
                      print(response.body);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to send request')),
                      );
                    }
                  },

                  child: Icon(Icons.post_add, color: Colors.white),
                ),
              ),
            ],
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
