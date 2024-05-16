import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Image_P extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<Image_P> {
  XFile? _image; 

  Future getImage(bool isCamera) async {
    XFile? image;

    if (isCamera) {
      image = await ImagePicker().pickImage(source: ImageSource.camera);
    } else {
      image = await ImagePicker().pickImage(source: ImageSource.gallery);
    }

    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selector'),
      ),
      body: Center(
        child: Column(children: <Widget>[
          IconButton(
            icon: Icon(Icons.insert_drive_file),
            onPressed: () {
              getImage(false);
            },
          ),
          SizedBox(
            height: 10.0,
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () {
              getImage(true);
            },
          ),
          _image == null
              ? Container()
              : Image.file(
                  File(_image!.path), 
                  height: 300.0,
                  width: 300.0,
                )
        ]),
      ),
    );
  }
}
