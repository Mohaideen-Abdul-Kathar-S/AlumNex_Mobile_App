import 'dart:convert';

import 'package:alumnex/alumn_global.dart';
import 'package:alumnex/alumnex_database_connection_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AlumnexInsideCollegePage extends StatefulWidget {
  final dynamic rollno;

  const AlumnexInsideCollegePage({super.key, required this.rollno});

  @override
  State<AlumnexInsideCollegePage> createState() =>
      _AlumnexInsideCollegePageState();
}

class _AlumnexInsideCollegePageState extends State<AlumnexInsideCollegePage> {
  late final rollno;
  late Future<List<dynamic>> _postsFuture;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rollno = widget.rollno;
    _postsFuture = fetchPosts();
  }

  Future<List<dynamic>> fetchPosts() async {
    final response = await http.get(
      Uri.parse('$urI/get_posts'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load posts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading posts.'));
          } else {
            final posts =
                snapshot.data!
                    .where((post) => post['postType'] == "Inside")
                    .toList();

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.black38,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: FutureBuilder<String>(
                                  future: DataBaseConnection()
                                      .getProfileImageUrl(post['postId']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return SizedBox(
                                        height: 60,
                                        width: 60,
                                        child: CircularProgressIndicator(),
                                      );
                                    } else if (snapshot.hasError ||
                                        !snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return Image.asset(
                                        "assets/logo.jpg", // Fallback if error or empty
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover,
                                      );
                                    } else {
                                      return Image.network(
                                        snapshot.data!,
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover,
                                      );
                                    }
                                  },
                                ),
                              ),

                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post['title'] ?? 'Unknown',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      post['content'] ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.keyboard_double_arrow_right),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child:
                                post['postImageId'] != null
                                    ? Image.network(
                                      '$urI/get-post-image/${post['postImageId']}',
                                      height: 300,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                height: 300,
                                                color: Colors.grey[300],
                                                child: Center(
                                                  child: Text(
                                                    'Image Not Found',
                                                  ),
                                                ),
                                              ),
                                    )
                                    : Container(
                                      height: 300,
                                      color: Colors.grey[300],
                                      child: Center(child: Text('No Image')),
                                    ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  FutureBuilder<int>(
                                    future: DataBaseConnection()
                                        .getUserLikeState(
                                          post['_id'].toString(),
                                          rollno,
                                        ),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Icon(
                                          Icons.thumb_up_alt_outlined,
                                        );
                                      }
                                      int likeState = snapshot.data!;

                                      return IconButton(
                                        icon: Icon(
                                          likeState == 1
                                              ? Icons.thumb_up
                                              : Icons.thumb_up_alt_outlined,
                                        ),
                                        onPressed: () async {
                                          dynamic data = {
                                            '_id': post['_id'],
                                            'rollno': rollno,
                                          };
                                          await DataBaseConnection()
                                              .update_likes(data);
                                          // Call setState to refresh FutureBuilder after like toggling
                                          setState(() {
                                            //likeState = likeState == 1 ? 0 : 1;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                  FutureBuilder<List<int>>(
                                      future: DataBaseConnection().getLikes(
                                        post['_id'].toString(),
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Text("...");
                                        } else if (snapshot.hasError) {
                                          return Text("Error");
                                        } else {
                                          return Text('${snapshot.data?[0]} Likes');
                                        }
                                      },
                                    ),
                                ],
                              ),

                              Column(
                                children: [
                                  Icon(Icons.comment),
                                  FutureBuilder<List<int>>(
                                      future: DataBaseConnection().getLikes(
                                        post['_id'].toString(),
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Text("...");
                                        } else if (snapshot.hasError) {
                                          return Text("Error");
                                        } else {
                                          return Text('${snapshot.data?[1]} Commands');
                                        }
                                      },
                                    ),
                                ],
                              ),
                              Column(
                                children: [Icon(Icons.share), Text('Share')],
                              ),
                              Column(
                                children: [Icon(Icons.bookmark), Text('Save')],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
