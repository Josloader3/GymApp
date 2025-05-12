import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class UserRepository {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveUserData(GymUser user) async {
    await _database.child('users').child(user.uid).set(user.toMap());
  }

  Future<GymUser?> getUserData(String userId) async {
    final snapshot = await _database.child('users').child(userId).get();
    if (snapshot.exists) {
      return GymUser.fromMap(Map<String, dynamic>.from(snapshot.value as Map));
    }
    return null;
  }

  Future<void> updateUserProfile(GymUser user) async {
    await _database.child('users').child(user.uid).update({
      'name': user.name,
      'age': user.age,
      'fitnessLevel': user.fitnessLevel,
      'photoUrl': user.photoUrl,
    });
  }
}
