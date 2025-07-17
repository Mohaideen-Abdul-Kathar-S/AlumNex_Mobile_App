import 'package:flutter/material.dart';

class AlumnexLeaderboardPage extends StatefulWidget {
  const AlumnexLeaderboardPage({super.key});

  @override
  State<AlumnexLeaderboardPage> createState() => _AlumnexLeaderboardPageState();
}

class _AlumnexLeaderboardPageState extends State<AlumnexLeaderboardPage> {
   @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alumnnex Leaderboard',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: LeaderboardPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}


class Student {
  final String name;
  final int points;
  final String avatarUrl;

  Student(this.name, this.points, this.avatarUrl);
}

class LeaderboardPage extends StatelessWidget {
  final List<Student> students = [
    Student("Bryan Wolf", 43, "https://i.pravatar.cc/150?img=1"),
    Student("Meghan Jes", 40, "https://i.pravatar.cc/150?img=2"),
    Student("Alex Turner", 38, "https://i.pravatar.cc/150?img=3"),
    Student("Marsha Fisher", 36, "https://i.pravatar.cc/150?img=4"),
    Student("Juanita Cormier", 35, "https://i.pravatar.cc/150?img=5"),
    Student("You", 34, "https://i.pravatar.cc/150?img=6"),
    Student("Tamara Schmidt", 33, "https://i.pravatar.cc/150?img=7"),
    Student("Ricardo Veum", 32, "https://i.pravatar.cc/150?img=8"),
    Student("Gary Sanford", 31, "https://i.pravatar.cc/150?img=9"),
    Student("Becky Bartell", 30, "https://i.pravatar.cc/150?img=10"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Leaderboard")),
      body: Column(
        children: [
          _buildTop3(context),
          Expanded(child: _buildList(context)),
        ],
      ),
    );
  }

  Widget _buildTop3(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTopUser(context, students[1], 2),
          _buildTopUser(context, students[0], 1, crown: true),
          _buildTopUser(context, students[2], 3),
        ],
      ),
    );
  }

  Widget _buildTopUser(BuildContext context, Student student, int rank, {bool crown = false}) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            CircleAvatar(radius: 30, backgroundImage: NetworkImage(student.avatarUrl)),
            if (crown)
              Positioned(
                top: -10,
                child: Icon(Icons.emoji_events, color: Colors.green, size: 28),
              ),
          ],
        ),
        SizedBox(height: 6),
        Text(student.name, style: TextStyle(fontWeight: FontWeight.bold)),
        Text("${student.points} pts", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final isYou = student.name == "You";

        return Container(
          color: isYou ? Colors.greenAccent.withOpacity(0.2) : Colors.transparent,
          child: ListTile(
            leading: Text(
              '${index + 1}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            title: Text(student.name),
            trailing: Text("${student.points} pts"),
          ),
        );
      },
    );
  }
}