import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';


class AlumnexResumePage extends StatefulWidget {
  final String rollno;

  const AlumnexResumePage({super.key, required this.rollno});

  @override
  State<AlumnexResumePage> createState() => _AlumnexResumePageState();
}

class _AlumnexResumePageState extends State<AlumnexResumePage> {
  File? _resumeFile;

  @override
  void initState() {
    super.initState();
    _fetchResume();
  }

  Future<void> _fetchResume() async {
    final url = Uri.parse('http://10.149.248.153:5000/get-resume/${widget.rollno}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/resume_${widget.rollno}.pdf');
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        _resumeFile = file;
      });
    } else {
      print('❌ Resume not found.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(title: Text('View Resume')),
  body: Center(
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _resumeFile != null
              ? Image.file(
                  _resumeFile!,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                )
              : Image.network(
                  'http://10.149.248.153:5000/get-resume/${widget.rollno}',
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 400,
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.insert_drive_file,
                        size: 80,
                        color: Colors.grey.shade700,
                      ),
                    );
                  },
                ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'My Resume',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ),
  ),
);

  }
}
