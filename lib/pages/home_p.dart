import 'dart:async';

import 'package:calculatorapp/components/box.dart';
import 'package:calculatorapp/components/button.dart';
import 'package:calculatorapp/main.dart';
import 'package:calculatorapp/pages/about.dart';
import 'package:calculatorapp/pages/auth_page.dart';
import 'package:calculatorapp/pages/calculator.dart';
import 'package:calculatorapp/pages/compass.dart';
import 'package:calculatorapp/pages/contact.dart';
import 'package:calculatorapp/pages/home.dart';
import 'package:calculatorapp/pages/lightsensor.dart';
import 'package:calculatorapp/pages/login_or_register_oages.dart';
import 'package:calculatorapp/pages/login_page.dart';
import 'package:calculatorapp/pages/map_page.dart';
import 'package:calculatorapp/pages/result_page.dart';
import 'package:calculatorapp/pages/sensor_data_page.dart';
import 'package:calculatorapp/pages/sign_up.dart';
import 'package:calculatorapp/pages/step_counter.dart';
import 'package:calculatorapp/theme/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:calculatorapp/service/database.dart';
import 'package:calculatorapp/pages/create_quiz.dart';
import 'package:calculatorapp/pages/quiz_play.dart';
import 'package:calculatorapp/widget/widget.dart';
import 'package:uuid/uuid.dart';

class UserHome extends StatefulWidget {
  @override
  State<UserHome> createState() => _UserHomeState();
}

void signUserOut(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
  );
}

class _UserHomeState extends State<UserHome> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> quizStream;
  late DatabaseService databaseService;
  late Timer _timer;
  final int sessionTimeoutInSeconds = 900000;

  @override
  void initState() {
    super.initState();
    databaseService = DatabaseService(uid: Uuid().v4());
    quizStream = Stream.empty();
    loadQuizData();
    _startTimeout();
  }

  @override
  void dispose() {
    _timer.cancel(); // Dispose of the session timeout timer
    super.dispose();
  }

  void _startTimeout() {
    _timer = Timer(Duration(seconds: sessionTimeoutInSeconds), () {
      // Show popup message when session times out
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('Session Timeout'),
            content: Text('Your session has timed out. Please login again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Redirect user to login page
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => LoginOrRegisterPage(),
                  ));
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }

  void _resetTimeout() {
    _timer.cancel(); // Cancel the current timer
    _startTimeout(); // Start a new timer
  }

  void loadQuizData() {
    databaseService.getQuizData2().then((value) {
      setState(() {
        quizStream = value;
      });
      displayNewQuizNotification();
    });
  }

  void displayNewQuizNotification() {
    NotificationService.displayNotification(
      'New Quiz Added!',
      'Check out the latest quiz available.',
    );
  }

  Widget quizList() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: StreamBuilder(
          stream: quizStream,
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('No quizzes available.'),
              );
            }
            String userId = FirebaseAuth.instance.currentUser!.uid;
            return ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemExtent: 180,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var quizDoc = snapshot.data!.docs[index];
                String quizId = quizDoc.id;
                String imageUrl = quizDoc.data()['quizImgUrl'];
                String title = quizDoc.data()['quizTitle'];
                String description = quizDoc.data()['quizDesc'];
                return QuizTile(
                  imageUrl: imageUrl,
                  title: title,
                  description: description,
                  id: quizId,
                  userId: userId,
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context).themeData;
    _resetTimeout();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: AppLogo(),
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.brown,
        actions: [
          Row(
            children: [
              MyBox(
                color: Colors.brown,
                children: [
                  Text(
                    'Theme',
                    style: TextStyle(color: Colors.white),
                  ),
                  MyButton(
                    color: Colors.brown,
                    onTap: () {
                      Provider.of<ThemeProvider>(context, listen: false)
                          .toggleTheme();
                    },
                  )
                ],
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.brown,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    DrawerHeader(
                      child: Center(
                        child: Text(
                          'M E N U',
                          style: TextStyle(fontSize: 50),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.home),
                      title: Text(
                        'Home',
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => HomePage()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.calculate),
                      title: Text(
                        'Calculator',
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Calculator()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.message),
                      title: Text(
                        'About Me',
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => About()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.message),
                      title: Text(
                        'Contacts',
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MyContact()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.score),
                      title: Text(
                        'Results',
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => QuizResultsPage(
                                userId:
                                    FirebaseAuth.instance.currentUser!.uid)));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.light),
                      title: Text(
                        'Light Sensor',
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => LightSensorPage()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.countertops_sharp),
                      title: Text(
                        'Step Counter',
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => StepCounterPage()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.gps_fixed),
                      title: Text(
                        'Location',
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => GoogleMapPage()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.compass_calibration),
                      title: Text(
                        'Compass',
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Compass_Page()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.sensors),
                      title: Text(
                        'Sensor Data',
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SensorDataPage()));
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text(
                  'Log out',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () => signUserOut(context),
              ),
            ],
          ),
        ),
      ),
      body: quizList(),
    );
  }
}

class QuizTile extends StatelessWidget {
  final String imageUrl, title, id, description, userId;

  QuizTile({
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.id,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    if (userId == null || id == null) {
      return Container(); // or handle null case as appropriate
    }
    return FutureBuilder<bool>(
      future: checkCompletion(userId!, id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(); // Return an empty container while loading
        } else if (snapshot.hasError) {
          return Container(); // Return an empty container if an error occurs
        } else {
          bool isCompleted = snapshot.data ?? false;
          if (isCompleted) {
            // If the quiz is completed, return an empty container to hide it
            return Container();
          } else {
            // If the quiz is not completed, return a clickable tile
            return GestureDetector(
              onTap: () async {
                String currentDate = DateTime.now().toIso8601String();
                String resultId = Uuid().v4();
                FirebaseFirestore firestore = FirebaseFirestore.instance;
                try {
                  await firestore.collection('quizResults').doc(resultId).set({
                    'userID': userId,
                    'quizID': id,
                    'score': 0,
                    'status': 'in progress',
                    'dateCompleted': null,
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizPlay(id),
                    ),
                  );
                } catch (error) {
                  print('Error recording quiz result: $error');
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                height: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                      ),
                      Container(
                        color: Colors.black26,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                description,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        }
      },
    );
  }

  Future<bool> checkCompletion(String userId, String quizId) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('quizResults')
          .where('userID', isEqualTo: userId)
          .where('quizID', isEqualTo: quizId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking completion: $e");
      return false;
    }
  }
}
