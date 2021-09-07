import 'package:flutter/foundation.dart';

import '../models/user.dart';

class TaggedUsers with ChangeNotifier {
  String id;
  List<User> _users = [];

  static List<TaggedUsers> _archive = [];

  TaggedUsers({this.id});

  List<User> of({@required String id}) {
    if (_archive.any((element) => element.id == id)) {
      return _archive.firstWhere((element) => element.id == id)._users;
    } else {
      final result = TaggedUsers(id: id);
      _archive.add(result);
      return result._users;
    }
  }

  void addTo({@required User user, @required String id}) {
    if (!_archive.any((element) => element.id == id)) {
      throw Exception(
          "there is no list of id $id in archive - please instantiate it first");
    } else {
      this.of(id: id).add(user);
      notifyListeners();
    }
  }

  void removeFrom({@required User user, @required String id}) {
    if (!_archive.any((element) => element.id == id)) {
      throw Exception();
    } else {
      this.of(id: id).remove(user);
      notifyListeners();
    }
  }

  void reset({@required String id}) {
    if (!_archive.any((element) => element.id == id)) {
      return;
    } else {
      _archive.firstWhere((element) => element.id == id)._users = [];
    }
  }

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    if (other is TaggedUsers) {
      TaggedUsers otherTaggedUsers = other;
      return this.id == otherTaggedUsers.id;
    } else {
      return false;
    }
  }
}
