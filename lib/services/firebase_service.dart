import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class FirebaseService {
  FirebaseService();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _usersCollection = 'users';
  final String _postsCollection = 'posts';
  Map? currentUser;

  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required File image,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
      String userId = userCredential.user!.uid;
      String fileName = Timestamp.now().millisecondsSinceEpoch.toString() + path.extension(image.path);
      UploadTask task = _storage.ref('images/$userId/$fileName').putFile(image);
      return await task.then((snapshot) async {
        String downloadUrl = await snapshot.ref.getDownloadURL();
        await _db.collection(_usersCollection).doc(userId).set({
          'name': name,
          'email': email,
          'image': downloadUrl,
        });
        return true;
      });
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        currentUser = await _getUserData(userId: userCredential.user!.uid);
        return true;
      }
      else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> logoutUser() {
    return _auth.signOut();
  }

  Future<Map> _getUserData({required String userId}) async {
    DocumentSnapshot doc = await _db.collection(_usersCollection).doc(userId).get();
    return doc.data() as Map;
  }

  Future<bool> createPost({required File image}) async {
    try {
      String userId = _auth.currentUser!.uid;
      String fileName = Timestamp.now().millisecondsSinceEpoch.toString() + path.extension(image.path);
      UploadTask task = _storage.ref('images/$userId/$fileName').putFile(image);
      return await task.then((snapshot) async {
        String downloadUrl = await snapshot.ref.getDownloadURL();
        await _db.collection(_postsCollection).add({
          'userId': userId,
          'timestamp': Timestamp.now(),
          'image': downloadUrl,
        });
        return true;
      });
    } catch (e) {
      print(e);
      return false;
    }
  }

  Stream<QuerySnapshot> getPosts() {
    return _db.collection(_postsCollection)
      .orderBy('timestamp', descending: true)
      .snapshots();
  }

  Stream<QuerySnapshot> getPostsByUser() {
    String userId = _auth.currentUser!.uid;
    return _db.collection(_postsCollection)
      .where('userId', isEqualTo: userId)
      //.orderBy('timestamp', descending: true)
      .snapshots();
  }
}