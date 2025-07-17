import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:alumnex/alumnex_add_meet_members_page.dart';
import 'package:alumnex/alumnex_create_meeting_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class AlumnexTabMeetPage extends StatefulWidget {
  final dynamic rollno; // user id

  const AlumnexTabMeetPage({super.key, required this.rollno});

  @override
  State<AlumnexTabMeetPage> createState() => _AlumnexTabMeetPageState();
}

class _AlumnexTabMeetPageState extends State<AlumnexTabMeetPage> {
  final Color primaryColor = const Color(0xFF004d52);
  final Color accentColor = const Color(0xFFe27c43);
  final Color secondaryColor = const Color(0xFF224146);
  List<dynamic> meetings = [];

  bool _notFound = false;

  List<dynamic> assignedMeetings = [];
  bool _noAssignedMeetings = false;

  @override
  void initState() {
    super.initState();
    fetchMeetings();
    fetchAssignedMeetings();
  }

  Future<void> fetchMeetings() async {
    final response = await http.get(
      Uri.parse('http://192.168.157.76:5000/meetings/${widget.rollno}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        meetings = json.decode(response.body);
        _notFound = false;
      });
    } else if (response.statusCode == 404) {
      setState(() {
        _notFound = true;
        meetings = [];
      });
    } else {
      print("Failed to load meetings");
    }
  }

  Future<void> fetchAssignedMeetings() async {
    final response = await http.get(
      Uri.parse(
        'http://192.168.157.76:5000/assigned_meetings/${widget.rollno}',
      ),
    );

    if (response.statusCode == 200) {
      setState(() {
        assignedMeetings = json.decode(response.body);
        _noAssignedMeetings = false;
      });
    } else if (response.statusCode == 404) {
      setState(() {
        assignedMeetings = [];
        _noAssignedMeetings = true;
      });
    } else {
      print("Failed to load assigned meetings");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: secondaryColor.withOpacity(0.05), // soft background
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top row: Create button and notification icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => CreateMeetPage(hostId: widget.rollno),
                    ),
                  );
                },
                icon: const Icon(Icons.video_call),
                label: const Text("Create Meet"),
              ),
              IconButton(
                icon: Icon(
                  Icons.notifications_none,
                  color: primaryColor,
                  size: 28,
                ),
                onPressed: () {
                  // TODO: handle notification click
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          /// Created Meetings Section
          Text(
            "Created Meetings",
            style: TextStyle(
              color: primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child:
                _notFound
                    ? const Center(child: Text("No meetings found."))
                    : meetings.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      itemCount: meetings.length,
                      itemBuilder: (context, index) {
                        final meeting = meetings[index];
                        return _buildMeetingTile(
                          meeting['title'],
                          "${meeting['date']}, ${meeting['start_time']}",
                          meeting['_id'],
                        );
                      },
                    ),
          ),

          const SizedBox(height: 16),

          /// Assigned Meetings Section
          Text(
            "Assigned Meetings",
            style: TextStyle(
              color: primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child:
                _noAssignedMeetings
                    ? const Center(child: Text("No assigned meetings found."))
                    : assignedMeetings.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      itemCount: assignedMeetings.length,
                      itemBuilder: (context, index) {
                        final meeting = assignedMeetings[index];
                        return _buildassignedMeetingTile(
                          meeting['title'],
                          "${meeting['date']}, ${meeting['start_time']}",
                          meeting['_id'],
                          meeting['link'],
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

Future<void> _launchURL(String link) async {
  final Uri uri = Uri.parse(link.startsWith('http') ? link : 'https://$link');

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch $link';
  }
}

  Widget _buildMeetingTile(String title, String dateTime, String meetId) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(Icons.video_camera_front, color: primaryColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(dateTime),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: secondaryColor,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => AlumnexAddMeetMembersPage(
                    rollno: widget.rollno,
                    meetId: meetId,
                  ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildassignedMeetingTile(
    String title,
    String dateTime,
    String meetId,
    String link,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(Icons.video_camera_front, color: primaryColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(dateTime),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: secondaryColor,
        ),
        onTap: () {
          _launchURL(link);
        },
      ),
    );
  }
}
