import 'package:calculatorapp/pages/admin_page.dart';
import 'package:calculatorapp/theme/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:calculatorapp/service/database.dart';
import 'package:calculatorapp/pages/add_questions.dart';
import 'package:calculatorapp/widget/widget.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const CreateQuiz());
  // Create an instance of the Uuid class
  var uuid = Uuid();

  // Generate a random UUID
  String randomUuid = uuid.v4();
  print('Random UUID: $randomUuid');
}


class CreateQuiz extends StatelessWidget {
  const CreateQuiz({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Page(),
    );
  }
}


class Page extends StatefulWidget {
  const Page({super.key});

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  DatabaseService databaseService =
      new DatabaseService(uid: Uuid().v4());

  final _formKey = GlobalKey<FormState>();

  late String quizImgUrl, quizTitle, quizDesc;

  bool isLoading = false;
  late String quizId;

  void createQuiz() {
  quizId = randomAlphaNumeric(16);
  if (_formKey.currentState!.validate()) {
    setState(() {
      isLoading = true;
    });

    Map<String, String> quizData = {
      "quizImgUrl": quizImgUrl,
      "quizTitle": quizTitle,
      "quizDesc": quizDesc
    };

    databaseService.addQuizData(quizData, quizId).then((value) {
      setState(() {
        isLoading = false;
      });



      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AddQuestion(
            quizId: quizId, 
            databaseService: databaseService,
          ),
        ),
      );
    }).catchError((error) {
      print(error);

      // Navigate to the AddQuestion page with the quiz ID even if there's an error
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AddQuestion(
            quizId: quizId, // Pass the quiz ID to AddQuestion page
            databaseService: databaseService,
          ),
        ),
      );
    });
  }
}

  @override
  Widget build(BuildContext context) {
    // final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(onPressed: () => AdminPage(),),
        title: AppLogo(),
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.orange,
        //brightness: Brightness.li,
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              TextFormField(
                validator: (val) =>
                    val!.isEmpty ? "Enter Quiz Image Url" : null,
                decoration:
                    InputDecoration(hintText: "Quiz Image Url (Optional)"),
                onChanged: (val) {
                  setState(() {
                    quizImgUrl = val;
                  });
                },
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                validator: (val) =>
                    val!.isEmpty ? "Enter Quiz Title" : null,
                decoration: InputDecoration(hintText: "Quiz Title"),
                onChanged: (val) {
                  setState(() {
                    quizTitle = val;
                  });
                },
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                validator: (val) =>
                    val!.isEmpty ? "Enter Quiz Description" : null,
                decoration: InputDecoration(hintText: "Quiz Description"),
                onChanged: (val) {
                  setState(() {
                    quizDesc = val;
                  });
                },
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  createQuiz();
                },
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                      color: Colors.brown,
                      borderRadius: BorderRadius.circular(30)),
                  child: Text(
                    "Create Quiz",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
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
