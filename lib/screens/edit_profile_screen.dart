import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../widgets/edit_profile/user_image_picker.dart';
import './profile_screen.dart';
import '../providers/current_user.dart';

class EditProfileScreen extends StatefulWidget {
  static final routeName = '/edit-profile';

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File _oldImagefile;
  String _userImageURL;
  var _isInit = true;
  final _formKey = GlobalKey<FormState>();
  final _nameFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  var _initValues = {
    'username': '',
    'name': '',
  };

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final _userData = Provider.of<CurrentUser>(context, listen: false);
      _initValues = {
        'username': _userData.user.username,
        'name': _userData.user.name,
      };
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  void uploadImageFile(File imageFile) async {
    print('uploadImageFile - initialised');
    final currentUser = FirebaseAuth.instance.currentUser;

    final ref = FirebaseStorage.instance
        .ref()
        .child('user_image')
        .child(currentUser.uid + '.jpg');
    print(currentUser.uid);
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    print(userData['imageUrl']);
    if (_oldImagefile == null &&
        userData != null &&
        userData['imageUrl'] != null) {
      _oldImagefile = await _getFileFromUrl(userData['imageUrl']);
    }
    await ref.putFile(imageFile);
    print('uploadImageFile - upload complete');
    _userImageURL = await ref.getDownloadURL();
    print('uploadImageFile - userImageURL generated');
  }

  Future<File> _getFileFromUrl(String url) async {
    // download image
    final response = await http.get(Uri.parse(url));

    // create empty file
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File(path.join(documentDirectory.path, 'empty.png'));

    file.writeAsBytesSync(response.bodyBytes);
    return file;
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState.save();
  }

  void updateCloudFireStore() async {
    await _saveForm();
    final currentUser = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    print('updateCloudFireStore - initialised');
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .set(
      {
        'email': userData['email'],
        'username': _initValues['username'],
        'name': _initValues['name'],
        'imageUrl':
            _userImageURL == null ? userData['imageUrl'] : _userImageURL,
        'chats': userData['chats'],
      },
    );
    print('updateCloudFirestore - updated');
  }

  void _navigateBack(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(0.0, -1.0);
          var end = Offset.zero;
          var curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        pageBuilder: (context, animation, animationTime) {
          return ProfileScreen();
        },
        transitionDuration: Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: BackButton(
          onPressed: () {
            if (_oldImagefile != null) {
              uploadImageFile(_oldImagefile);
            }
            _navigateBack(context);
          },
        ),
        actions: [
          TextButton(
            child: Text(
              'Done',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            onPressed: () async {
              await updateCloudFireStore();
              await Provider.of<CurrentUser>(context, listen: false).update();
              _navigateBack(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  UserImagePicker(uploadImageFile),
                  Divider(
                    thickness: 1,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Name'),
                    textInputAction: TextInputAction.next,
                    initialValue: _initValues['name'],
                    focusNode: _nameFocusNode,
                    onSaved: (value) {
                      _initValues = {
                        'username': _initValues['username'],
                        'name': value
                      };
                    },
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Username'),
                    textInputAction: TextInputAction.next,
                    initialValue: _initValues['username'],
                    focusNode: _usernameFocusNode,
                    onSaved: (value) {
                      _initValues = {
                        'username': value,
                        'name': _initValues['name']
                      };
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
