import 'dart:io';

import 'package:flutter/material.dart';

class FileProvider extends ChangeNotifier {
  String id;
  File _file;

  static List<FileProvider> _archive = [];

  FileProvider({this.id});

  File of({@required String id}) {
    if (_archive.any((element) => element.id == id)) {
      return _archive.firstWhere((element) => element.id == id)._file;
    } else {
      final result = FileProvider(id: id);
      _archive.add(result);
      return result._file;
    }
  }

  void set({@required File file, @required String id}) {
    if (!_archive.any((element) => element.id == id)) {
      throw Exception(
          "there is no file of $id in archive - please instantiate it first");
    } else {
      _archive.firstWhere((element) => element.id == id)._file = file;
      notifyListeners();
    }
  }

  void reset({@required String id}) {
    if (!_archive.any((element) => element.id == id)) {
      return;
    } else {
      _archive.firstWhere((element) => element.id == id)._file = null;
    }
  }

  void resetArchive() {
    _archive = [];
  }

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    if (other is FileProvider) {
      FileProvider otherFileProvider = other;
      return this.id == otherFileProvider.id;
    } else {
      return false;
    }
  }
}
