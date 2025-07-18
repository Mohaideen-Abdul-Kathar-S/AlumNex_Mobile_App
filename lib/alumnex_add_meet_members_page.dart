import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlumnexAddMeetMembersPage extends StatefulWidget {
  final dynamic rollno;
  final dynamic meetId;

  const AlumnexAddMeetMembersPage({
    super.key,
    required this.rollno,
    required this.meetId,
  });

  @override
  State<AlumnexAddMeetMembersPage> createState() =>
      _AlumnexAddMeetMembersPageState();
}

class _AlumnexAddMeetMembersPageState extends State<AlumnexAddMeetMembersPage> {
  final Color primaryColor = const Color(0xFF004d52);
  final Color accentColor = const Color(0xFFe27c43);
  final Color secondaryColor = const Color(0xFF224146);
  Map<String, dynamic>? meetingData;
  TextEditingController searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchMeetingDetails();
  }

  Future<void> fetchMeetingDetails() async {
    final response = await http.get(
      Uri.parse('http://192.168.157.76:5000/meeting_detail/${widget.meetId}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        meetingData = json.decode(response.body);
      });
    } else {
      print("Failed to fetch meeting data");
    }
  }

  Future<void> searchStudent(String query) async {
    final response = await http.get(
      Uri.parse('http://192.168.157.76:5000/students/search?query=$query'),
    );
    if (response.statusCode == 200) {
      setState(() {
        _searchResults = json.decode(response.body);
      });
    } else {
      print("Search failed");
    }
  }

  Future<void> addMember(String studentRoll) async {
    final response = await http.post(
      Uri.parse(
        'http://192.168.157.76:5000/meeting/${widget.meetId}/add_member',
      ),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'rollno': studentRoll}),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Member added successfully")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to add member")));
    }
  }

  Future<void> addGroupMembers(String groupType) async {
    final response = await http.post(
      Uri.parse(
        'http://192.168.157.76:5000/meeting/${widget.meetId}/add_group',
      ),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'group': groupType}),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Group members added")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to add group members")));
    }
  }

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final res = await http.get(
      Uri.parse('http://192.168.157.76:5000/search_users?q=$query'),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() => _searchResults = data.take(4).toList());
      print(_searchResults);
    } else {
      print("Failed to fetch users");
    }
  }

  Future<void> _addMemberToMeeting(String studentId) async {
    final response = await http.post(
      Uri.parse('http://192.168.157.76:5000/add_member_meet'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"meet_id": widget.meetId, "student_id": studentId}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData["message"] ?? "Success")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to add member")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Members to Meet",
          style: TextStyle(
            color: accentColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        elevation: 5,
        toolbarHeight: 100,
        shadowColor: accentColor,
        backgroundColor: primaryColor,
        foregroundColor: accentColor,
        actions: [
          Container(
            width: 250,
            height: 40,
            margin: EdgeInsets.only(top: 30, bottom: 30),
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              border: Border.all(color: accentColor, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: accentColor),
                SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    cursorColor: accentColor,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search & Add Student',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                    onChanged: (value) {
                      // Add search logic here
                      print('Searching for: $value');

                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(Duration(milliseconds: 300), () {
                        searchUsers(value);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            meetingData == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._searchResults.map((student) {
                        return ListTile(
                          title: Text(
                            "${student['_id']} (${student['rollno']})",
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              _addMemberToMeeting(student['_id']);
                              setState(() {
                                
                                fetchMeetingDetails();
                              });
                            },
                            child: const Text("Add"),
                          ),
                        );
                      }),

                      // 📝 Meeting Title
                      Text(
                        meetingData!['title'] ?? 'No Title',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 📅 Date and Time
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text("Date: ${meetingData!['date']}"),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Time: ${meetingData!['start_time']} - ${meetingData!['end_time']}",
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // 🌐 Platform
                      Row(
                        children: [
                          const Icon(
                            Icons.videocam,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text("Platform: ${meetingData!['platform']}"),
                        ],
                      ),

                      // 🔗 Link
                      Row(
                        children: [
                          const Icon(Icons.link, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              meetingData!['link'],
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 30, thickness: 1.5),

                      // 👨‍🏫 Host ID
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text("Host ID: ${meetingData!['host_id']}"),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 👥 Members
                      const Text(
                        "Members Added:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      (meetingData!['members'] != null &&
                              meetingData!['members'].isNotEmpty)
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                              meetingData!['members'].length,
                              (index) {
                                return Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(meetingData!['members'][index]),
                                  ],
                                );
                              },
                            ),
                          )
                          : const Text(
                            "No members added yet.",
                            style: TextStyle(color: Colors.redAccent),
                          ),

                      const Divider(),
                      // 🔍 Search and Add Member

                      // 👥 Add Group/Community Members
                      const Text(
                        "Add by Group",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        spacing: 10,
                        children: [
                          ElevatedButton(
                            onPressed: () => addGroupMembers("community"),
                            child: const Text("Add Community Members"),
                          ),
                          ElevatedButton(
                            onPressed: () => addGroupMembers("mentoring"),
                            child: const Text("Add Mentoring Members"),
                          ),
                          ElevatedButton(
                            onPressed: () => addGroupMembers("connection"),
                            child: const Text("Add Connection Members"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
