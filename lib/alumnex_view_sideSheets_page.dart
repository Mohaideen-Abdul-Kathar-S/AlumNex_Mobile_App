import 'package:alumnex/alumn_global.dart';
import 'package:flutter/material.dart';

class AlumnexViewSidesheetsPage extends StatefulWidget {
  final dynamic roll;

  const AlumnexViewSidesheetsPage({super.key,required this.roll});

  @override
  State<AlumnexViewSidesheetsPage> createState() =>
      _AlumnexViewSidesheetsPageState();
}

class _AlumnexViewSidesheetsPageState extends State<AlumnexViewSidesheetsPage> {
  final Color primaryColor = const Color(0xFF004d52);
  final Color accentColor = const Color(0xFFe27c43);
  final Color secondaryColor = const Color(0xFF224146);

  bool isEdit = false;
  final Map<String, TextEditingController> controllers = {};
  late final roll;
  @override
  void initState() {
    super.initState();
    roll = widget.roll;
    // Initialize controllers for each editable field
    person.forEach((key, value) {
      if (value is String) {
        controllers[key] = TextEditingController(text: value);
      }
    });
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: TextStyle(
          color: accentColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String key,) {
    final value = person[key];

    if (value is List) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            
              Text(value.join(", "), style: TextStyle(color: Colors.grey[800])),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                "$label:",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              flex: 3,
              child:
                  isEdit  && controllers.containsKey(key)
                      ? TextField(
                        controller: controllers[key],
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                        ),
                      )
                      : Text(
                        value.toString(),
                        style: TextStyle(color: Colors.grey[800]),
                      ),
            ),
          ],
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: secondaryColor,
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Hi!!!, it's ${person['name']}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildSectionTitle("BASIC INFORMATION"),
                _buildInfoRow("Gender", "Gender"),
                _buildInfoRow("Email ID", "email"),
                _buildInfoRow("Phone Number", "phoneno"),
                _buildInfoRow("Location", "location"),

                _buildSectionTitle("ACADEMIC DETAILS"),
                _buildInfoRow(
                  "Programme & Branch",
                  "programbranch",
                
                ),
                _buildInfoRow("Current Year", "year",),
                _buildInfoRow("Batch", "Batch", ),
                _buildInfoRow("Roll Number", "_id", ),

                _buildSectionTitle("CAREER INTERESTS"),
                _buildInfoRow("Domain", "domain"),
                _buildInfoRow("Preferred Roles", "preferredroll"),
                _buildInfoRow("Higher Studies", "Higherstudies"),
                _buildInfoRow("Target Companies", "Dreamcompany"),

                _buildSectionTitle("SKILLS & ACHIEVEMENTS"),
                _buildInfoRow("Technical Skills", "TechSkills"),
                _buildInfoRow("Certifications", "certificaion"),
                _buildInfoRow("Projects", "projects"),
                _buildInfoRow("Clubs/Leadership", "clubs"),

                if (roll == "Alumni") ...[
                  _buildSectionTitle("CAREER INFORMATION"),
                  _buildInfoRow("Current Job Title", "currentjob"),
                  _buildInfoRow("Company", "company"),
                  _buildInfoRow("Years of Experieance", "yoe"),
                  _buildInfoRow("Worked In", "workedin"),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
