import 'package:calculatorapp/pages/about.dart';
import 'package:calculatorapp/pages/auth_page.dart';
import 'package:calculatorapp/pages/login_or_register_oages.dart';
import 'package:calculatorapp/widget/widget.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class MyContact extends StatefulWidget {
  @override
  _MyContactPageState createState() => _MyContactPageState();
}

void signUserOut(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
  );
}

class _MyContactPageState extends State<MyContact> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppLogo(),
        centerTitle: true,
        backgroundColor: Colors.orange,
        actions: [
        IconButton(
          onPressed: () => signUserOut(context), // Pass a callback function
          icon: Icon(Icons.logout),
        )
        ],
      ),
      body: Container(
        height: double.infinity,
        child: FutureBuilder(
          future: getContacts(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return const Center(
                child: SizedBox(height: 50, child: CircularProgressIndicator()),
              );
            }
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  Contact contact = snapshot.data[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      radius: 20,
                      child: Icon(Icons.person),
                    ),
                    title: Text(contact.displayName),
                    subtitle: Column(children: [
                      Text(contact.phones[0]),
                    ]),
                  );
                });
          },
        ),
      ),
    );
  }

  Future<List<Contact>> getContacts() async {
    bool isGranted = await Permission.contacts.status.isGranted;
    if (!isGranted) {
      isGranted = await Permission.contacts.request().isGranted;
    }
    if (isGranted) {
      return await FastContacts.allContacts;
    }
    return [];
  }
}
