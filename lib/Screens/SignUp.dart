import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taar3/Screens/ChatRoom.dart';
import 'package:taar3/Widgets/Widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUp extends StatefulWidget {
  final Function toggleView;
  SignUp(this.toggleView);
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController usernameEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  final formKey = GlobalKey<FormState>();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('user');

  bool isLoading = false;

  Future<void> signUp() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
    }
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailEditingController.text,
        password: passwordEditingController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        SnackBar(content: Text('The password provided is too weak.'));
      } else if (e.code == 'email-already-in-use') {
        SnackBar(content: Text('The account already exists for that email.'));
      }
    } catch (e) {
      print(e);
    }
  }

  addUser() {
    // Call the user's CollectionReference to add a new user
    return users
        .add({
          'userId': usernameEditingController.text,
          'email': emailEditingController.text,
          'password': passwordEditingController.text
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                alignment: Alignment.bottomCenter,
                child: Container(
                  // alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        children: [
                          Image.asset("assets/images/logo1.png"),
                          SizedBox(height: 20),
                          Form(
                            key: formKey,
                            child: Column(children: [
                              TextFormField(
                                controller: usernameEditingController,
                                style: textfieldStyle(),
                                decoration:
                                    textFieldInputDecoration("username"),
                                validator: (val) {
                                  return val.isEmpty || val.length < 3
                                      ? "Enter Username 3+ characters"
                                      : null;
                                },
                              ),
                              TextFormField(
                                controller: emailEditingController,
                                style: textfieldStyle(),
                                decoration: textFieldInputDecoration("email"),
                                validator: (val) {
                                  return RegExp(
                                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                          .hasMatch(val)
                                      ? null
                                      : "Enter correct email";
                                },
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                obscureText: true,
                                controller: passwordEditingController,
                                style: textfieldStyle(),
                                decoration:
                                    textFieldInputDecoration("password"),
                                validator: (val) {
                                  return val.length < 6
                                      ? "Enter Password 6+ characters"
                                      : null;
                                },
                              ),
                            ]),
                          ),
                          SizedBox(height: 30),
                          GestureDetector(
                            onTap: () {
                              signUp().then((_) {
                                addUser();
                              }).then((_) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoom(),
                                    ));
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xff007EF4),
                                      const Color(0xff2A75BC)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(30)),
                              child: Text(
                                "Sign up",
                                style: textfieldStyle(),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          // Container(
                          //   alignment: Alignment.center,
                          //   width: MediaQuery.of(context).size.width,
                          //   padding: EdgeInsets.symmetric(vertical: 20),
                          //   decoration: BoxDecoration(
                          //       color: Colors.white,
                          //       borderRadius: BorderRadius.circular(30)),
                          //   child: Text(
                          //     "Sign in with Google",
                          //     style: TextStyle(color: Colors.black, fontSize: 16),
                          //   ),
                          // ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Already have an account?",
                                  style: textfieldStyle()),
                              TextButton(
                                onPressed: () {
                                  widget.toggleView();
                                },
                                child: Text(
                                  "Sign in",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
