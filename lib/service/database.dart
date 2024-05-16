import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  final String uid;
  late DatabaseHelper dbHelper;

  DatabaseService({required this.uid}) {
    dbHelper = DatabaseHelper();
  }

  Future<void> addData(Map<String, dynamic> userData) async {
    await FirebaseFirestore.instance
        .collection("users")
        .add(userData)
        .catchError((e) {
      print(e);
    });
  }

  getData() async {
    return await FirebaseFirestore.instance.collection("users").snapshots();
  }

  Future<void> addQuizData(Map<String, dynamic> quizData, String quizId) async {
    await FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .set(quizData)
        .catchError((e) {
      print(e);
    });

    await dbHelper.insertQuiz(quizData);
  }

  Future<void> addQuestion(
      String quizId, Map<String, dynamic> questionData) async {
    try {
      await FirebaseFirestore.instance
          .collection('Quiz')
          .doc(uid)
          .collection('QNA')
          .add(questionData);
    } catch (e) {
      print('Error adding question: $e');
    }
    await dbHelper.insertQuestion(questionData, quizId);
  }

  Future<void> addQuestionData(
      Map<String, dynamic> questionData, String quizId) async {
    await FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .collection("QNA")
        .add(questionData)
        .catchError((e) {
      print(e);
    });
    await dbHelper.insertQuestion(questionData, quizId);
  }

  getQuizData(String quizId) async {
    return await FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .get();
  }

  getQuizData2() async {
    return await FirebaseFirestore.instance.collection("Quiz").snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getQuizData3(String quizId) {
    return FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .snapshots();
  }

  getQuestionData(String quizId) async {
    return await FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .collection("QNA")
        .get();
  }

  Stream<QuerySnapshot> getQuestionData2(String quizId) {
    return FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .collection("QNA")
        .snapshots();
  }

  Future<void> updateQuizData(
      String quizId, Map<String, dynamic> updatedData) async {
    await FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .update(updatedData)
        .catchError((e) {
      print(e);
    });
    await dbHelper.updateQuiz(quizId, updatedData);
  }

  Future<void> updateQuestionData(String quizId, String questionId,
      Map<String, dynamic> updatedData) async {
    await FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .collection("QNA")
        .doc(questionId)
        .update(updatedData)
        .catchError((e) {
      print(e);
    });
    await dbHelper.updateQuestion(questionId, updatedData, quizId);
  }

  Future<void> deleteQuestion(String quizId, String questionId) async {
    await FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .collection("QNA")
        .doc(questionId)
        .delete()
        .catchError((e) {
      print(e);
    });
    await dbHelper.deleteQuestion(questionId, quizId);
  }

  Future<List<Map<String, dynamic>>> getOfflineQuizResults() async {
    try {
      // Retrieve quiz results from SQLite
      List<Map<String, dynamic>> quizResults =
          await dbHelper.getOfflineQuizResults(uid);
      return quizResults;
    } catch (e) {
      print("Error getting offline quiz results: $e");
      throw Exception('Failed to get offline quiz results');
    }
  }

  Future<String> getQuizIdByTitle(String quizTitle) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Quiz') // Assuming your collection is named 'Quiz'
        .where('title', isEqualTo: quizTitle)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot
          .docs.first.id; // Return the ID of the first matching document
    } else {
      throw Exception('Quiz with title $quizTitle not found');
    }
  }

  Future<void> deleteQuiz(String quizId) async {
    await FirebaseFirestore.instance
        .collection("Quiz")
        .doc(quizId)
        .delete()
        .catchError((e) {
      print(e);
    });
    await dbHelper.deleteQuiz(quizId);
  }

  // Function to sync data from Firestore to SQLite
  Future<void> syncDataFromFirestoreToSQLite() async {
    // Retrieve quiz data from Firestore
    QuerySnapshot<Map<String, dynamic>> quizSnapshot =
        await FirebaseFirestore.instance.collection("Quiz").get();

    // Loop through each quiz document
    for (QueryDocumentSnapshot<Map<String, dynamic>> quizDocument
        in quizSnapshot.docs) {
      Map<String, dynamic> quizData = quizDocument.data();

      // Store quiz data in SQLite
      await dbHelper.insertQuiz(quizData);

      String quizTitle = quizData['quizTitle'];
      String quizId = quizDocument.id;
      await dbHelper.updateQuizTitle(quizId, quizTitle);

      // Retrieve question data for the current quiz from Firestore
      QuerySnapshot<Map<String, dynamic>> questionSnapshot =
          await FirebaseFirestore.instance
              .collection("Quiz")
              .doc(quizDocument.id)
              .collection("QNA")
              .get();

      // Loop through each question document
      for (QueryDocumentSnapshot<Map<String, dynamic>> questionDocument
          in questionSnapshot.docs) {
        Map<String, dynamic> questionData = questionDocument.data();

        // Store question data in SQLite
        await dbHelper.insertQuestion(questionData, quizDocument.id);
      }
    }
  }
}

class DatabaseHelper {
  static Database? _database;
  static final _databaseName = 'quiz.db';
  static final _databaseVersion = 1;

  static final tableQuiz = 'quiz';
  static final tableQuestion = 'question';
  static final tableQuizResults = 'quiz_results';
  static final columnUserId = 'user_id';

  static final columnId = 'id';
  static final columnUrl = 'imgUrl';
  static final columnTitle = 'title';
  static final columnDescription = 'description';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableQuiz (
        $columnId INTEGER PRIMARY KEY,
        $columnUrl TEXT NOT NULL,
        $columnTitle TEXT NOT NULL,
        $columnDescription TEXT NOT NULL
      )
    ''');

    // Add more tables if needed
  }

  Future<List<Map<String, dynamic>>> getOfflineQuizResults(
      String userId) async {
    Database db = await database;
    return await db.query(
      tableQuizResults,
      where: '$columnUserId = ?',
      whereArgs: [userId],
    );
  }

  Future<int> updateQuizTitle(String quizId, String quizTitle) async {
    Database db = await database;
    return await db.update(
      tableQuiz,
      {columnTitle: quizTitle},
      where: '$columnId = ?',
      whereArgs: [quizId],
    );
  }

  Future<int> insertQuiz(Map<String, dynamic> quizData) async {
    Database db = await database;
    return await db.insert(tableQuiz, quizData);
  }

  Future<int> insertQuestion(
      Map<String, dynamic> questionData, String quizId) async {
    Database db = await database;
    // Insert question with quizId
    return await db.insert(tableQuestion, questionData);
  }

  Future<int> updateQuiz(
      String quizId, Map<String, dynamic> updatedData) async {
    Database db = await database;
    return await db.update(
      tableQuiz,
      updatedData,
      where: '$columnId = ?',
      whereArgs: [quizId],
    );
  }

  Future<int> updateQuestion(String questionId,
      Map<String, dynamic> updatedData, String quizId) async {
    Database db = await database;
    // Update question with quizId
    return await db.update(
      tableQuestion,
      updatedData,
      where: '$columnId = ? AND quizId = ?',
      whereArgs: [questionId, quizId],
    );
  }

  Future<int> deleteQuiz(String quizId) async {
    Database db = await database;
    return await db.delete(
      tableQuiz,
      where: '$columnId = ?',
      whereArgs: [quizId],
    );
  }

  Future<int> deleteQuestion(String questionId, String quizId) async {
    Database db = await database;
    // Delete question with quizId
    return await db.delete(
      tableQuestion,
      where: '$columnId = ? AND quizId = ?',
      whereArgs: [questionId, quizId],
    );
  }

  // Add more CRUD operations as needed...
}
