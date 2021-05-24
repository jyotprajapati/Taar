import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:taar3/Helper/authenticate.dart';
import 'package:taar3/Screens/ChatRoom.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  bool userIsLoggedIn = false;

  @override
  void initState() {
    // getLoggedInState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return MaterialApp(
            title: "FlutterChat",
            home: Scaffold(
              body: Center(
                child: Text("Oops! something went wrong!"),
              ),
            ),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'FlutterChat',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: Color(0xff145C9E),
              scaffoldBackgroundColor: Color(0xff1F1F1F),
              accentColor: Color(0xff007EF4),
              fontFamily: "OverpassRegular",
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (ctx, AsyncSnapshot<User> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    // if user is signed in
                    return ChatRoom();
                  } else {
                    // if user is not signed in
                    return Authenticate();
                  }
                }

                // if user is not signed in
                return Authenticate();
              },
            ),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return MaterialApp(
          title: "FlutterChat",
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}
