// ignore_for_file: prefer_const_constructors, avoid_print, unused_import

import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_overlay/loading_overlay.dart';
import './welcome_screen.dart';
import 'chat_screen.dart';
import '../components/rounded_button.dart';
import '../constants.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({Key? key}) : super(key: key);
  static const String id = 'info';

  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: LoadingOverlay(
        isLoading: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            children: [
              SizedBox(
                height: 100,
              ),
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: SizedBox(
                    height: 350,
                    child: Image.asset('images/founder.jpeg'),
                  ),
                ),
              ),
              SizedBox(
                height: 18,
              ),
              SingleChildScrollView(
                // for Vertical scrolling
                scrollDirection: Axis.vertical,
                child: Text(
                  "Hello, I'm Oğuzhan ÇART,   "
                  " I made a simple chat application for you. You can think of the application as a chat room."
                  "Access is restricted with the People Registration and Login system. You can chat safely. ☺️.        ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    letterSpacing: 3,
                    wordSpacing: 3,
                  ),
                ),
              ),
              RoundedButton(
                title: 'Info Page',
                colour: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(context, WelcomeScreen.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
