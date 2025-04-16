import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  //Register
  Future<void> createUser({
    required String name,
    required String surname,
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .set({'firstName': name, 'lastName': surname, 'email': email});
        print("Kullanıcı başarıyla kaydedildi.");
      }
    } catch (e) {
      print("Kayıt hatası: $e");
    }
  }

  //Login

  Future<void> signIn({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message: 'E-posta veya şifre boş olamaz!',
      );
    }
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      print("Giriş başarılı: ${userCredential.user?.email}");
    } on FirebaseAuthException catch (e) {
      print("Giriş hatası: ${e.message}");
      throw e;
    }
  }

  Future<String?> getUserName() async {
    try {
      if (currentUser != null) {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser!.uid)
                .get();

        if (userDoc.exists && userDoc['firstName'] != null) {
          return userDoc['firstName']; 
        } else {
          print("Kullanıcı adı bulunamadı.");
          return "User"; 
        }
      } else {
        print("currentUser null.");
        return "User"; 
      }
    } catch (e) {
      print("Ad alma hatası: $e");
      return "User";
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
