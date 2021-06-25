import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File pickedImage) uploadImageFile;

  UserImagePicker(this.uploadImageFile);

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File _newImage;

  void _pickImage() async {
    final picker = ImagePicker();
    // adjust getting image setting here
    final pickedImage =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 70);
    print('_pickImage - image retrieved from user gallery');
    final pickedImageFile = File(pickedImage.path);
    setState(
      () {
        _newImage = pickedImageFile;
      },
    );
    widget.uploadImageFile(_newImage);
  }

  @override
  Widget build(BuildContext context) {
    print('UserImagePicker - build');
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading...');
        }
        return Column(
          children: <Widget>[
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey,
              backgroundImage: _newImage == null
                  ? userSnapshot.data['imageUrl'] == null
                      ? AssetImage('./assets/images/dummy_user.png')
                      : NetworkImage(userSnapshot.data['imageUrl'])
                  : FileImage(_newImage),
            ),
            FlatButton(
              onPressed: _pickImage,
              child: Text(
                'Change profile photo',
                style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
