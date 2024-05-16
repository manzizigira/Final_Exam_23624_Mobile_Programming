import 'dart:async';

import 'package:calculatorapp/pages/about.dart';
import 'package:calculatorapp/pages/results.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:calculatorapp/model/question_model.dart';
import 'package:calculatorapp/service/database.dart';
import 'package:calculatorapp/widget/widget.dart';
import 'package:calculatorapp/widgets/quiz_play_widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class QuizPlay extends StatefulWidget {
  final String quizId;
  QuizPlay(this.quizId);

  @override
  _QuizPlayState createState() => _QuizPlayState();
}

int _correct = 0;
int _incorrect = 0;
int _notAttempted = 0;
int total = 0;

/// Stream
late StreamController<List<int>> infoStreamController;
late Stream<List<int>> infoStream;

class _QuizPlayState extends State<QuizPlay> {
  late QuerySnapshot questionSnaphot;
  late String _userId;
  late List<DocumentSnapshot> questionSnapshots;
  late DatabaseService databaseService;
  int currentIndex = 0;
  late StreamController<List<int>> infoStreamController;
  bool isLoading = true;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    // Initialize the database service with a unique ID
    databaseService = DatabaseService(uid: Uuid().v4());
    infoStream = Stream<List<int>>.periodic(Duration(milliseconds: 100), (x) {
      print("this is x $x");
      return [_correct, _incorrect];
    });
    databaseService.getQuestionData(widget.quizId).then((value) {
      questionSnaphot = value;
      _notAttempted = questionSnaphot.docs.length;
      _correct = 0;
      _incorrect = 0;
      isLoading = false;
      total = questionSnaphot.docs.length;
      setState(() {
        questionSnapshots = value.docs;
      });
      print("init don $total ${widget.quizId} ");
    });

    // ignore: unnecessary_null_comparison
    if (infoStream == null) {
      infoStream = Stream<List<int>>.periodic(Duration(milliseconds: 100), (x) {
        // print("this is x $x");
        return [_correct, _incorrect];
      });
    }

    super.initState();
    _userId = FirebaseAuth.instance.currentUser!.uid;
  }

  // Future<void> updateQuizResults() async {
  //   final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //   try {
  //     // Update Firestore with quiz results
  //     await firestore.collection('quizResults').add({
  //       'userID': _userId,
  //       'quizID': widget.quizId,
  //       'score': _correct,
  //       'totalQuestions': total,
  //       'dateCompleted': Timestamp.now(),
  //     });
  //   } catch (error) {
  //     print('Error updating quiz results: $error');
  //   }
  // }

  // Function to handle quiz completion
  void handleQuizCompletion() {
    // Calculate the score and total questions
    total = _correct + _incorrect + _notAttempted;

    // Update quiz results in Firestore
    // updateQuizResults();
  }
  
  void moveToNextQuestion() {
    setState(() {
      currentIndex = (currentIndex + 1) % questionSnapshots.length;
    });
  }

  // void sendNotification() async {
  //   final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //   final String userId = FirebaseAuth.instance.currentUser!.uid;
  //   final String quizId = widget.quizId;

  //   try {
  //     final QuerySnapshot querySnapshot = await firestore
  //         .collection('quizResults')
  //         .where('userID', isEqualTo: userId)
  //         .where('quizID', isEqualTo: quizId)
  //         .limit(1)
  //         .get();

  //     if (querySnapshot.docs.isNotEmpty) {
  //       // Update existing quiz result document
  //       final DocumentSnapshot quizResult = querySnapshot.docs.first;
  //       await quizResult.reference.update({
  //         'score': _correct,
  //         'status': 'completed',
  //         'dateCompleted': Timestamp.now(),
  //       });
  //     } else {
  //       // Create new quiz result document
  //       await firestore.collection('quizResults').add({
  //         'userID': userId,
  //         'quizID': quizId,
  //         'score': _correct,
  //         'status': 'completed',
  //         'dateCompleted': Timestamp.now(),
  //       });
  //     }
  //   } catch (error) {
  //     print('Error updating/creating quiz result: $error');
  //   }
  // }

  QuestionModel getQuestionModelFromDatasnapshot(
      DocumentSnapshot questionSnapshot) {
    QuestionModel questionModel = QuestionModel();

    var data = questionSnapshot.data() as Map<String, dynamic>?;

    if (data != null) {
      questionModel.question = (data["question"] as String?)!;

      // Check if question is not null before processing
      // ignore: unnecessary_null_comparison
      if (questionModel.question != null) {
        List<String> options = [
          data["option1"],
          data["option2"],
          data["option3"],
          data["option4"],
        ];
        options.shuffle();

        questionModel.option1 = options[0];
        questionModel.option2 = options[1];
        questionModel.option3 = options[2];
        questionModel.option4 = options[3];
        questionModel.correctOption = data["option1"];
        questionModel.answered = false;

        print(questionModel.correctOption.toLowerCase());
      }
    }

    return questionModel;
  }

  @override
  void dispose() {
    if (infoStream == null) {
      infoStreamController = StreamController<List<int>>.broadcast();
      infoStream = infoStreamController.stream;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppLogo(),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: questionSnapshots == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${currentIndex + 1} of ${questionSnapshots.length}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 16.0),
                    QuizPlayTile(
                      questionModel: getQuestionModelFromDatasnapshot(
                        questionSnapshots[currentIndex],
                      ),
                      index: currentIndex,
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: currentIndex == questionSnapshots.length - 1
                          ? null
                          : moveToNextQuestion,
                      child: Text('Next'),
                    ),
                    SizedBox(height: 16.0),
                    if (currentIndex == questionSnapshots.length - 1)
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to the results page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Results(
                                correct: _correct,
                                incorrect: _incorrect,
                                total: total,
                                quizId: widget.quizId,
                              ),
                            ),
                          );
                        },
                        child: Text('Complete Quiz'),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class InfoHeader extends StatefulWidget {
  final int length;

  InfoHeader({required this.length});

  @override
  _InfoHeaderState createState() => _InfoHeaderState();
}

class _InfoHeaderState extends State<InfoHeader> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: infoStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Container(
                  height: 40,
                  margin: EdgeInsets.only(left: 14),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    children: <Widget>[
                      NoOfQuestionTile(
                        text: "Total",
                        number: widget.length,
                      ),
                      NoOfQuestionTile(
                        text: "Correct",
                        number: _correct,
                      ),
                      NoOfQuestionTile(
                        text: "Incorrect",
                        number: _incorrect,
                      ),
                      NoOfQuestionTile(
                        text: "NotAttempted",
                        number: _notAttempted,
                      ),
                    ],
                  ),
                )
              : Container();
        });
  }
}

class QuizPlayTile extends StatefulWidget {
  final QuestionModel questionModel;
  final int index;

  QuizPlayTile({required this.questionModel, required this.index});

  @override
  _QuizPlayTileState createState() => _QuizPlayTileState();
}

class _QuizPlayTileState extends State<QuizPlayTile> {
  String optionSelected = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Q${widget.index + 1} ${widget.questionModel.question}",
              style:
                  TextStyle(fontSize: 18, color: Colors.black.withOpacity(0.8)),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          GestureDetector(
            onTap: () {
              if (!widget.questionModel.answered) {
                ///correct
                if (widget.questionModel.option1 ==
                    widget.questionModel.correctOption) {
                  setState(() {
                    optionSelected = widget.questionModel.option1;
                    widget.questionModel.answered = true;
                    _correct = _correct + 1;
                  });
                } else {
                  setState(() {
                    optionSelected = widget.questionModel.option1;
                    widget.questionModel.answered = true;
                    _incorrect = _incorrect + 1;
                  });
                }
                setState(() {
                  _notAttempted = _notAttempted - 1;
                });
              }
            },
            child: OptionTile(
              option: "A",
              description: "${widget.questionModel.option1}",
              correctAnswer: widget.questionModel.correctOption,
              optionSelected: optionSelected,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          GestureDetector(
            onTap: () {
              if (!widget.questionModel.answered) {
                ///correct
                if (widget.questionModel.option2 ==
                    widget.questionModel.correctOption) {
                  setState(() {
                    optionSelected = widget.questionModel.option2;
                    widget.questionModel.answered = true;
                    _correct = _correct + 1;
                  });
                } else {
                  setState(() {
                    optionSelected = widget.questionModel.option2;
                    widget.questionModel.answered = true;
                    _incorrect = _incorrect + 1;
                  });
                }
                setState(() {
                  _notAttempted = _notAttempted - 1;
                });
              }
            },
            child: OptionTile(
              option: "B",
              description: "${widget.questionModel.option2}",
              correctAnswer: widget.questionModel.correctOption,
              optionSelected: optionSelected,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          GestureDetector(
            onTap: () {
              if (!widget.questionModel.answered) {
                ///correct
                if (widget.questionModel.option3 ==
                    widget.questionModel.correctOption) {
                  setState(() {
                    optionSelected = widget.questionModel.option3;
                    widget.questionModel.answered = true;
                    _correct = _correct + 1;
                  });
                } else {
                  setState(() {
                    optionSelected = widget.questionModel.option3;
                    widget.questionModel.answered = true;
                    _incorrect = _incorrect + 1;
                  });
                }
                setState(() {
                  _notAttempted = _notAttempted - 1;
                });
              }
            },
            child: OptionTile(
              option: "C",
              description: "${widget.questionModel.option3}",
              correctAnswer: widget.questionModel.correctOption,
              optionSelected: optionSelected,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          GestureDetector(
            onTap: () {
              if (!widget.questionModel.answered) {
                ///correct
                if (widget.questionModel.option4 ==
                    widget.questionModel.correctOption) {
                  setState(() {
                    optionSelected = widget.questionModel.option4;
                    widget.questionModel.answered = true;
                    _correct = _correct + 1;
                  });
                } else {
                  setState(() {
                    optionSelected = widget.questionModel.option4;
                    widget.questionModel.answered = true;
                    _incorrect = _incorrect + 1;
                  });
                }
                setState(() {
                  _notAttempted = _notAttempted - 1;
                });
              }
            },
            child: OptionTile(
              option: "D",
              description: "${widget.questionModel.option4}",
              correctAnswer: widget.questionModel.correctOption,
              optionSelected: optionSelected,
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
