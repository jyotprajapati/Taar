import 'package:firebase_auth/firebase_auth.dart';
import 'package:taar3/Model/User.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  UserDetails _userFromFirebaseUser(User user) {
    return user != null ? UserDetails(uid: user.uid) : null;
  }
}
