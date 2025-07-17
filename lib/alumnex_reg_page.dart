import 'package:alumnex/alumnex_database_connection_page.dart';
import 'package:alumnex/alumnex_login_page.dart';
import 'package:flutter/material.dart';

class AlumnexRegPage extends StatefulWidget {
  const AlumnexRegPage({super.key});

  @override
  State<AlumnexRegPage> createState() => _AlumnexRegPageState();
}

class _AlumnexRegPageState extends State<AlumnexRegPage> {
  String? selectedRole = "Select Role";
  final Color primaryColor = const Color(0xFF004d52);
  final Color accentColor = const Color(0xFFe27c43);
  final Color secondaryColor = const Color(0xFF224146);
  final TextEditingController rollnoCont = TextEditingController();
  final TextEditingController emailCont = TextEditingController();
  final TextEditingController passwordCont = TextEditingController();
  final TextEditingController conPasswordCont = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AlumNex'),
        shadowColor: accentColor,
        toolbarHeight: 100,
        backgroundColor: primaryColor,
        elevation: 3,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          color: accentColor,
          fontSize: 24,
        ),
        foregroundColor: accentColor,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004D52), Color(0xFF224146)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Register Page',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 30),

                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: selectedRole,
                    dropdownColor: Colors.white,
                    items:
                        ['Select Role', 'Student', 'Alumni'].map((role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  buildTextField("Enter Roll No", rollnoCont),
                  const SizedBox(height: 15),
                  buildTextField("Enter Email Id", emailCont),
                  const SizedBox(height: 15),
                  buildTextField("Enter Password", passwordCont, obscure: true),
                  const SizedBox(height: 15),
                  buildTextField(
                    "Confirm Password",
                    conPasswordCont,
                    obscure: true,
                  ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF004D52),
                          elevation: 5,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AlumnexLoginPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE27C43),
                          foregroundColor: Colors.white,
                          elevation: 5,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (passwordCont.text == conPasswordCont.text) {
                            dynamic data = {
  "roll" : selectedRole,
  "_id": rollnoCont.text,
  "password": passwordCont.text,
  "profile": "Path",
  "name": "Nill",
  "Gender": "Nill",
  "email": emailCont.text,
  "phoneno": "Nill",
  "location": "Nill",
  "programbranch": "Nill",
  "Batch": "Nill",
  "preferredroll": "Nill",
  "Higherstudies": "Nill",
  "Dreamcompany": "Nill",
  "TechSkills": "Nill",
  "certificaion": "Nill",
  "projects": "Nill",
  "clubs": "Nill",
  "mentoredby":"Nill",
  "domain":"Nill",
  "currentjob": "Nill",
  "company": "Nill",
  "yoe": "Nill",
  "workedin": "Nill",
  "mentoring":[],
};
                            String res = await DataBaseConnection().RegistrationPage(data);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text( res ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password isn\'t match'),
                              ),
                            );
                          }
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AlumnexLoginPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Register",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController cont, {
    bool obscure = false,
  }) {
    return TextField(
      controller: cont,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: label,
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
