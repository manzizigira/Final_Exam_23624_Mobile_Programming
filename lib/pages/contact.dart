import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class MyContact extends StatefulWidget {
  @override
  _MyContactPageState createState() => _MyContactPageState();
}

class _MyContactPageState extends State<MyContact> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Contacts App'),
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
