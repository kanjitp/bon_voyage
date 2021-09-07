import 'dart:io';

import 'package:dotted_border/dotted_border.dart';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'create_post_screen.dart';

import '../../../providers/file_provider.dart';

class PostImagePicker extends StatefulWidget {
  @override
  _PostImagePickerState createState() => _PostImagePickerState();
}

class _PostImagePickerState extends State<PostImagePicker> {
  File imageFile;
  String _userImageURL;
  var _isInit = true;
  final _formKey = GlobalKey<FormState>();
  final _nameFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();

  double maxWidth;
  double maxHeight;
  @override
  void initState() {
    super.initState();
  }

  get http => null;

  get path => null;

  @override
  void didChangeDependencies() {
    maxWidth = MediaQuery.of(context).size.width;
    maxHeight = MediaQuery.of(context).size.width;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  void _pickImage() async {
    final picker = ImagePicker();
    // adjust getting image setting here
    final pickedImage = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 100,
        maxHeight: maxHeight,
        maxWidth: maxWidth);
    print('_pickImage - image retrieved from user gallery');
    File croppedFile = await ImageCropper.cropImage(
      aspectRatio: CropAspectRatio(ratioX: maxWidth, ratioY: maxHeight),
      maxWidth: maxWidth.toInt(),
      maxHeight: maxHeight.toInt(),
      sourcePath: pickedImage.path,
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ]
          : [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9,
            ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      iosUiSettings: IOSUiSettings(
        title: 'Cropper',
      ),
    );
    if (croppedFile != null) {
      setState(
        () {
          Provider.of<FileProvider>(context, listen: false)
              .set(file: croppedFile, id: CreatePostScreen.id);
        },
      );
    }
  }

  void _takePhoto() async {
    final picker = ImagePicker();
    final photo = await picker.getImage(
        source: ImageSource.camera,
        imageQuality: 100,
        maxHeight: maxHeight,
        maxWidth: maxWidth);
    final pickedImageFile = File(photo.path);
    setState(
      () {
        imageFile = pickedImageFile;
      },
    );
  }

  void _pickMultipleImage() async {
    final picker = ImagePicker();
    final List<PickedFile> pickedImages =
        await picker.getMultiImage(imageQuality: 100);
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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    imageFile = Provider.of<FileProvider>(context).of(id: CreatePostScreen.id);
    var imagePicker = Container(
      margin: EdgeInsets.only(bottom: mediaQuery.size.height * 0.01),
      height: maxHeight,
      width: maxWidth,
      color: Colors.grey[200],
      child: Container(
        padding: EdgeInsets.symmetric(vertical: mediaQuery.size.height * 0.05),
        margin: EdgeInsets.symmetric(horizontal: mediaQuery.size.width * 0.05),
        child: DottedBorder(
          borderType: BorderType.RRect,
          dashPattern: [6, 3],
          radius: Radius.circular(12),
          child: Container(
            color: Colors.white,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(
                    Icons.image,
                    size: 50,
                    color: Colors.black45,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          _takePhoto();
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Icon(Icons.camera),
                            SizedBox(
                              width: 5,
                            ),
                            Text('Take a photo'),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).accentColor,
                            elevation: 5),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          _pickImage();
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Icon(Icons.image),
                            SizedBox(
                              width: 5,
                            ),
                            Text('Upload Image'),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).accentColor,
                            elevation: 5),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return imageFile == null
        ? imagePicker
        : Stack(
            children: [
              Container(
                height: maxHeight,
                width: maxWidth,
                child: GestureDetector(
                  onTap: () async {
                    _pickImage();
                    setState(() {});
                  },
                  child: Image.file(
                    imageFile,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.black38),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        imageFile = null;
                      });
                    },
                    icon: Icon(
                      Icons.clear,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}
