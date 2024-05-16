import 'package:calculatorapp/pages/admin_page.dart';
import 'package:calculatorapp/theme/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:calculatorapp/service/database.dart';
import 'package:calculatorapp/widget/widget.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddQuestion extends StatefulWidget {
  final String quizId;
  final DatabaseService databaseService;
  AddQuestion({required this.quizId, required this.databaseService});

  @override
  _AddQuestionState createState() => _AddQuestionState();
}

class _AddQuestionState extends State<AddQuestion> {
  DatabaseService databaseService = new DatabaseService(uid: Uuid().v4());
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  String question = "", option1 = "", option2 = "", option3 = "", option4 = "";

  void uploadQuizData() {
  if (_formKey.currentState!.validate()) {
    setState(() {
      isLoading = true;
    });

    Map<String, String> questionMap = {
      "question": question,
      "option1": option1,
      "option2": option2,
      "option3": option3,
      "option4": option4
    };

    widget.databaseService
        .addQuestionData(questionMap, widget.quizId)
        .then((value) {
      setState(() {
        isLoading = false;
        // Reset form fields after adding question
        _formKey.currentState!.reset();
        question = "";
        option1 = "";
        option2 = "";
        option3 = "";
        option4 = "";
      });
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // leading: BackButton(
        //   color: Colors.black54,
        // ),
        title: AppLogo(),
        elevation: 0.0,
        backgroundColor: Colors.orange,
        //brightness: Brightness.li,
      ),
      body: isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    TextFormField(
                      validator: (val) =>
                          val!.isEmpty ? "Enter Question" : null,
                      decoration: InputDecoration(hintText: "Question"),
                      onChanged: (val) {
                        question = val;
                      },
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      validator: (val) => val!.isEmpty ? "Option1 " : null,
                      decoration:
                          InputDecoration(hintText: "Option1 (Correct Answer)"),
                      onChanged: (val) {
                        option1 = val;
                      },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      validator: (val) => val!.isEmpty ? "Option2 " : null,
                      decoration: InputDecoration(hintText: "Option2"),
                      onChanged: (val) {
                        option2 = val;
                      },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      validator: (val) => val!.isEmpty ? "Option3 " : null,
                      decoration: InputDecoration(hintText: "Option3"),
                      onChanged: (val) {
                        option3 = val;
                      },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      validator: (val) => val!.isEmpty ? "Option4 " : null,
                      decoration: InputDecoration(hintText: "Option4"),
                      onChanged: (val) {
                        option4 = val;
                      },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Spacer(),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AdminPage()),
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width / 2 - 20,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 20),
                            decoration: BoxDecoration(
                                color: Colors.brown,
                                borderRadius: BorderRadius.circular(30)),
                            child: Text(
                              "Submit",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        GestureDetector(
                          onTap: () {
                            uploadQuizData();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width / 2 - 40,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 20),
                            decoration: BoxDecoration(
                                color: Colors.brown,
                                borderRadius: BorderRadius.circular(30)),
                            child: Text(
                              "Add Question",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 60,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
