import 'dart:io';
import 'dart:typed_data';

import '../../../models/user.dart' as user;
import '../../../providers/current_user.dart';
import '../../../providers/file_provider.dart';
import '../../../providers/taggedUsers.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:provider/provider.dart';

import './post_image_picker.dart';
import './location_confirmation.dart';
import './create_tag.dart';

class CreatePostScreen extends StatefulWidget {
  final LatLng latlng;
  final Uint8List screenshotData;
  static final String id = 'create-post';

  CreatePostScreen({@required this.latlng, @required this.screenshotData});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  var _postImageURL;
  final _captionFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  File _imageFile;
  String _caption;
  List<user.User> taggedUsers;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> uploadImageFile(File imageFile, String name) async {
    if (imageFile == null) return;
    print('uploadImageFile (post) - initialised');
    final currentUser = FirebaseAuth.instance.currentUser;

    final ref = FirebaseStorage.instance
        .ref()
        .child('post_image')
        .child(currentUser.uid)
        .child(name + '.jpg');

    await ref.putFile(imageFile);
    print('uploadImageFile - upload complete');
    _postImageURL = await ref.getDownloadURL();
    print('uploadImageFile - userImageURL generated');
  }

  Future<String> _createPost(
      {@required user.User currentUser,
      @required List<user.User> taggedUsers}) async {
    setState(() {
      _isLoading = true;
    });
    await _saveForm();

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.userId)
        .get();

    List<String> taggedUsersId = [];
    if (taggedUsers != null) {
      taggedUsers.forEach((user) {
        taggedUsersId.add(user.userId);
      });
    }

    final postData = await FirebaseFirestore.instance.collection('posts').add(
      {
        'creator': currentUser.userId,
        'imageUrl': _postImageURL,
        'caption': _caption,
        'likers': [],
        'comments': [],
        'tagged_users': taggedUsersId,
        'lat': widget.latlng.latitude,
        'lng': widget.latlng.longitude,
        'timestamp': Timestamp.now(),
      },
    );

    if (_imageFile != null) {
      await uploadImageFile(_imageFile, postData.id);
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postData.id)
          .update({'imageUrl': _postImageURL});
    }

    final postId = postData.id;

    // initialised
    List<String> newUserPosts;

    if (!userData.data().containsKey('posts')) {
      newUserPosts = [postId];
    } else {
      newUserPosts = [...userData['posts']];
      newUserPosts.add(postId);
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.userId)
        .update(
      {
        'posts': newUserPosts,
      },
    );

    taggedUsers.forEach(
      (user) async {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.userId)
            .get();

        // initialised
        List<String> newUserTaggedPosts;

        if (!userData.data().containsKey('tagged_posts')) {
          newUserTaggedPosts = [postId];
        } else {
          newUserTaggedPosts = [...userData['tagged_posts']];
          newUserTaggedPosts.add(postId);
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.userId)
            .update(
          {
            'tagged_posts': newUserTaggedPosts,
          },
        );
      },
    );

    print('post created successfully');
    setState(() {
      _isLoading = false;
    });
    return postId;
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState.save();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final userProvider = Provider.of<CurrentUser>(context, listen: false);
    taggedUsers = Provider.of<TaggedUsers>(context, listen: true)
        .of(id: CreatePostScreen.id);
    _imageFile = Provider.of<FileProvider>(context, listen: true)
        .of(id: CreatePostScreen.id);
    final appBar = PreferredSize(
      preferredSize: Size.fromHeight(mediaQuery.size.height * 0.075),
      child: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Create A New Memory',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : FlatButton(
                  onPressed: () async {
                    await _createPost(
                            currentUser: userProvider.user,
                            taggedUsers: taggedUsers)
                        .then((_) => Navigator.of(context).pop())
                        .then((_) => Navigator.of(context).pop());
                  },
                  child: Center(
                    child: Text(
                      'Create',
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontWeight: FontWeight.w700),
                    ),
                  ))
        ],
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(bottom: 10), child: PostImagePicker()),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: mediaQuery.size.width * 0.05,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Caption',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: Theme.of(context).splashColor),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20, bottom: 10),
                    padding: EdgeInsets.symmetric(
                        horizontal: mediaQuery.size.width * 0.02),
                    decoration: BoxDecoration(
                      color: Theme.of(context).splashColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      initialValue: "",
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          hintText: 'Say something about this location',
                          border: InputBorder.none),
                      textInputAction: TextInputAction.next,
                      maxLines: 4,
                      onSaved: (value) {
                        _caption = value;
                      },
                    ),
                  ),
                  SizedBox(height: mediaQuery.size.height * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LocationConfirmation(
                        currentLatLng: widget.latlng,
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        child: Image.memory(
                          widget.screenshotData,
                          fit: BoxFit.cover,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: mediaQuery.size.height * 0.03),
                  CreateTag(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
