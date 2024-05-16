import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:calculatorapp/widget/widget.dart';
import 'package:calculatorapp/service/database.dart';

class QuizResultsPage extends StatelessWidget {
  final String userId;

  QuizResultsPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppLogo(),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('quizResults')
            .where('userID', isEqualTo: userId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No quiz results found.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var quizResult = snapshot.data!.docs[index];
              String quizId = quizResult['quizID'];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Quiz')
                    .doc(quizId)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text(
                          'Quiz: Loading...'), // Placeholder text while loading
                      subtitle: Text('Score: ${quizResult['score']}'),
                      trailing: Text('Date: ${quizResult['dateCompleted']}'),
                    );
                  }
                  if (snapshot.hasError) {
                    return ListTile(
                      title: Text(
                          'Quiz: Error'), // Placeholder text if error occurs
                      subtitle: Text('Score: ${quizResult['score']}'),
                      trailing: Text('Date: ${quizResult['dateCompleted']}'),
                    );
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return ListTile(
                      title: Text(
                          'Quiz: Not found'), // Placeholder text if quiz not found
                      subtitle: Text('Score: ${quizResult['score']}'),
                      trailing: Text('Date: ${quizResult['dateCompleted']}'),
                    );
                  }
                  var quizData = snapshot.data!;
                  String quizTitle = quizData['quizTitle'];
                  return ListTile(
                    title: Text('Quiz: $quizTitle'), // Display the quiz title
                    subtitle: Text('Score: ${quizResult['score']}'),
                    trailing: Text('Date: ${quizResult['dateCompleted']}'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
