import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class CreateMeetPage extends StatefulWidget {
  final String hostId;

  const CreateMeetPage({super.key, required this.hostId});

  @override
  State<CreateMeetPage> createState() => _CreateMeetPageState();
}

class _CreateMeetPageState extends State<CreateMeetPage> {
  final _formKey = GlobalKey<FormState>();

  // Theme Colors
  final Color primaryColor = const Color(0xFF004d52);
  final Color accentColor = const Color(0xFFe27c43);
  final Color secondaryColor = const Color(0xFF224146);

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

// Inside _submitForm()
Future<void> _submitForm() async {
  if (_formKey.currentState!.validate() &&
      _selectedDate != null &&
      _startTime != null &&
      _endTime != null) {
    final meetData = {
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'date': formatDate(_selectedDate),
      'start_time': formatTime(_startTime),
      'end_time': formatTime(_endTime),
      'platform': 'Google Meet',
      'link': _linkController.text.trim(),
      'host_id': widget.hostId,
    };

    try {
      final response = await http.post(
        Uri.parse('http://192.168.157.76:5000/create-meet'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(meetData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Meet Created Successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server error.")),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please complete all fields.")),
    );
  }
}

  // Formatters
  String formatDate(DateTime? date) =>
      date != null ? DateFormat('yyyy-MM-dd').format(date) : 'Select Date';

  String formatTime(TimeOfDay? time) =>
      time != null ? time.format(context) : 'Select Time';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Create Meeting',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Create Meet",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    )),
                const SizedBox(height: 20),
                _buildTextField(_titleController, "Title"),
                const SizedBox(height: 12),
                _buildTextField(_descController, "Description", maxLines: 3),
                const SizedBox(height: 12),
                _buildDatePicker(),
                const SizedBox(height: 12),
                _buildTimePickers(),
                const SizedBox(height: 12),
                _buildPlatformSelector(),
                const SizedBox(height: 12),
                _buildTextField(_linkController, "Meeting Link"),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    ),
                    onPressed: _submitForm,
                    child: const Text("Create Meet",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: secondaryColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Enter $label' : null,
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(formatDate(_selectedDate),
            style: TextStyle(color: secondaryColor)),
      ),
    );
  }

  Widget _buildTimePickers() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (picked != null) {
                setState(() => _startTime = picked);
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Start Time',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child:
                  Text(formatTime(_startTime), style: TextStyle(color: secondaryColor)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (picked != null) {
                setState(() => _endTime = picked);
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'End Time',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child:
                  Text(formatTime(_endTime), style: TextStyle(color: secondaryColor)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformSelector() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Meeting Platform',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text('Google Meet', style: TextStyle(color: secondaryColor)),
    );
  }


}
