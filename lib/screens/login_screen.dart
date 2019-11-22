import 'package:flutter/material.dart';
import 'package:flash_chat/components/roundedbutton.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:io';
import 'package:toast/toast.dart';

enum authProblems { UserNotFound, PasswordNotValid, NetworkError }

class LoginScreen extends StatefulWidget {
  static const String id = 'LoginScreen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  final _auth = FirebaseAuth.instance;
  String email;
  String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration:
                    kInputTextDecoration.copyWith(hintText: 'Enter your email'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
                decoration: kInputTextDecoration.copyWith(
                    hintText: 'Enter your password'),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                text: 'Log In',
                color: Colors.lightBlueAccent,
                onPress: () async {
                  setState(() {
                    isLoading = true;
                  });
                  try {
                    final newUser = await _auth.signInWithEmailAndPassword(
                        email: email, password: password);
                    if (newUser != null) {
                      Navigator.pushNamed(context, ChatScreen.id);
                    }


                  } catch (e) {
                    authProblems errorType;
                    if (Platform.isAndroid) {
                      switch (e.message) {
                        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
                          errorType = authProblems.UserNotFound;
                          break;
                        case 'The password is invalid or the user does not have a password.':
                          errorType = authProblems.PasswordNotValid;
                          break;
                        case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
                          errorType = authProblems.NetworkError;
                          break;
                      // ...
                        default:
                          print('Case ${e.message} is not yet implemented');
                          Toast.show(e.message, context, duration: Toast.LENGTH_LONG, gravity:  Toast.CENTER,
                              backgroundColor: Colors.lightBlueAccent);
                      }
                    } else if (Platform.isIOS) {
                      switch (e.code) {
                        case 'Error 17011':
                          errorType = authProblems.UserNotFound;
                          break;
                        case 'Error 17009':
                          errorType = authProblems.PasswordNotValid;
                          break;
                        case 'Error 17020':
                          errorType = authProblems.NetworkError;
                          break;
                      // ...
                        default:
                          print('Case ${e.message} is not yet implemented');
                          Toast.show(e.message, context, duration: Toast.LENGTH_LONG, gravity:  Toast.CENTER,
                          backgroundColor: Colors.lightBlueAccent);

                      }
                    }
                    print('The error is $errorType');
                  } finally {
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
