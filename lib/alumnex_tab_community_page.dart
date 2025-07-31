import 'dart:convert';

import 'package:alumnex/alumnex_create_community_page.dart';
import 'package:alumnex/alumnex_create_group_page.dart';

import 'package:alumnex/alumnex_group_chat_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AlumnexTabCommunityPage extends StatefulWidget {
  final dynamic rollno;

  const AlumnexTabCommunityPage({super.key, required this.rollno});

  @override
  State<AlumnexTabCommunityPage> createState() =>
      _AlumnexTabCommunityPageState();
}

class _AlumnexTabCommunityPageState extends State<AlumnexTabCommunityPage> {
  final Color primaryColor = const Color(0xFF004d52);
  final Color accentColor = const Color(0xFFe27c43);
  final Color secondaryColor = const Color(0xFF224146);

  List<Map<String, String>> groups = [];

  List<Map<String, String>> communities = [];

  Future<List<Map<String, dynamic>>> _fetchGroups() async {
    print('Fetching groups for: ${widget.rollno}');

    final response = await http.get(
      Uri.parse('http://10.149.248.153:5000/get_groups/${widget.rollno}'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((group) {
        return {
          'name': group['name'],
          'type': group['type'],
          'id': group['id'],
        };
      }).toList();
    } else {
      throw Exception("Failed to load groups");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: secondaryColor.withOpacity(0.05),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Top row buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton("Create Group", Icons.group, () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            AlumnexCreateGroupPage(rollno: widget.rollno),
                  ),
                );
              }),
              _buildActionButton("Create Community", Icons.people_outline, () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            AlumnexCreateCommunityPage(rollno: widget.rollno),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 20),
          // Groups Section
          _buildSectionTitle("Groups"),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchGroups(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No groups available.'));
                }
            
                final fetchedGroups = snapshot.data!;
            
               return ListView(
        children: [
          ...fetchedGroups.map(
            (group) => _buildTile(
              group['name'],       // ✅ Fix here
              group['type'],
              group['id'], // Temporarily using 'description' as ID placeholder
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle("Communities"),
        ],
      );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTile(String name, String type, String groupId) {
    
    return Card(
      
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primaryColor,
          child: Icon(
            type == 'Group' ? Icons.group : Icons.apartment,
            color: Colors.white,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
        ),
        subtitle: Text(type),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 18,
          color: accentColor,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => AlumnexGroupChatPage(
                    sender: widget.rollno,
                    groupid: groupId,
                  ),
            ),
          );
        },
      ),
    );
  }
}
