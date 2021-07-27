import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class UserPresence {
  static final _app = Firebase.app();
  static final FirebaseDatabase _db = FirebaseDatabase(
    app: _app,
    databaseURL:
        'https://bonvoyage-orbital-default-rtdb.asia-southeast1.firebasedatabase.app/',
  );
  static rtdbAndLocalFsPresence() async {
    // All the refs required for updation
    try {
      print('UserPresnce - rtdbANdLocalFsPresence initiated');
      var uid = FirebaseAuth.instance.currentUser.uid;
      var userStatusDatabaseRef = _db.reference().child('/status/' + uid);
      var userStatusFirestoreRef =
          FirebaseFirestore.instance.collection('status').doc(uid);

      var isOfflineForDatabase = {
        "state": 'offline',
        "last_changed": ServerValue.timestamp,
      };

      var isOnlineForDatabase = {
        "state": 'online',
        "last_changed": ServerValue.timestamp,
      };

      // Firestore uses a different server timestamp value, so we'll
      // create two more constants for Firestore state.
      var isOfflineForFirestore = {
        "state": 'offline',
        "last_changed": FieldValue.serverTimestamp(),
      };

      var isOnlineForFirestore = {
        "state": 'online',
        "last_changed": FieldValue.serverTimestamp(),
      };
      _db
          .reference()
          .child('.info/connected')
          .onValue
          .listen((Event event) async {
        if (event.snapshot.value == false) {
          // Instead of simply returning, we'll also set Firestore's state
          // to 'offline'. This ensures that our Firestore cache is aware
          // of the switch to 'offline.'
          userStatusFirestoreRef.update(isOfflineForFirestore);
          return;
        }

        // currently only a dummy - need to sync with Cloud Functions
        // right now we use the sign out function
        await userStatusDatabaseRef
            .onDisconnect()
            .update(isOfflineForDatabase)
            .then((snap) {
          userStatusDatabaseRef.set(isOnlineForDatabase);

          // We'll also add Firestore set here for when we come online.
          userStatusFirestoreRef.update(isOnlineForFirestore);
        });
      });
    } catch (error) {
      print(error.message);
    }
  }

  static Future<void> forceUpdateOffline() async {
    try {
      var isOfflineForDatabase = {
        "state": 'offline',
        "last_changed": ServerValue.timestamp,
      };

      var isOfflineForFirestore = {
        "state": 'offline',
        "last_changed": FieldValue.serverTimestamp(),
      };

      var uid = FirebaseAuth.instance.currentUser.uid;
      var userStatusDatabaseRef = _db.reference().child('/status/' + uid);
      var userStatusFirestoreRef =
          FirebaseFirestore.instance.collection('status').doc(uid);
      await userStatusFirestoreRef.update(isOfflineForFirestore);
      await userStatusDatabaseRef.update(isOfflineForDatabase);
      print('forceUpdateOffline - done');
    } catch (error) {
      print(error.message);
    }
  }
}
