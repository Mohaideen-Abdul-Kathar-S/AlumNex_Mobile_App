import 'package:flutter/material.dart';

class AlumnexCreateCommunityPage extends StatefulWidget {
  final String rollno;

  const AlumnexCreateCommunityPage({super.key, required this.rollno});

  @override
  State<AlumnexCreateCommunityPage> createState() => _AlumnexCreateCommunityPageState();
}

class _AlumnexCreateCommunityPageState extends State<AlumnexCreateCommunityPage> {
  final TextEditingController _communityNameController = TextEditingController();
  List<String> existingGroups = ['Group A', 'Group B', 'Group C'];
  List<String> selectedGroups = [];

  void _createCommunity() {
    String name = _communityNameController.text.trim();
    if (name.isEmpty || selectedGroups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Community name and at least one group required')),
      );
      return;
    }

    // Example: send to backend
    Map<String, dynamic> community = {
      "name": name,
      "groups": selectedGroups,
      "created_by": widget.rollno,
      "created_at": DateTime.now().toIso8601String(),
    };

    print("Community Created: $community");

    // TODO: Replace print with backend API call
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Community")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _communityNameController,
              decoration: const InputDecoration(
                labelText: 'Community Name',
              ),
            ),
            const SizedBox(height: 20),
            const Text("Select Groups to Add", style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: existingGroups.length,
                itemBuilder: (context, index) {
                  String group = existingGroups[index];
                  bool isSelected = selectedGroups.contains(group);
                  return CheckboxListTile(
                    title: Text(group),
                    value: isSelected,
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          selectedGroups.add(group);
                        } else {
                          selectedGroups.remove(group);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _createCommunity,
              child: const Text("Create Community"),
            )
          ],
        ),
      ),
    );
  }
}
