import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Forgetpassword extends StatefulWidget {
  const Forgetpassword({super.key});

  @override
  State<Forgetpassword> createState() => _ForgetpasswordState();
}

class _ForgetpasswordState extends State<Forgetpassword> {
  double _imageOpacity = 0.0; // Opacity for image
  double _emailOpacity = 0.0; // Opacity for email field
  double _buttonsOpacity = 0.0; // Opacity for buttons

  String? email = '';

  @override
  void initState() {
    super.initState();

    // Control the delay of the appearance of elements
    Future.delayed(Duration(milliseconds: 1000), () {
      // Show image after 1000ms
      setState(() {
        _imageOpacity = 1.0;
      });
    });

    Future.delayed(Duration(milliseconds: 2000), () {
      // Show email field after 2000ms
      setState(() {
        _emailOpacity = 1.0;
      });
    });

    Future.delayed(Duration(milliseconds: 2400), () {
      setState(() {
        _buttonsOpacity = 1.0;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forget Password"),
        backgroundColor: Colors.blue,),
      body: SingleChildScrollView(
        child: Container(

          child: Form(child: Column(
            children: [
              AnimatedOpacity(
                opacity: _imageOpacity,
                duration: Duration(seconds: 2), // Slow transition for image
                child: Image.asset("imgs/project_logo.png"),
              ),
              Container(
                width: 320,
                height: 850,
              child:Column(
                children: [
                  AnimatedOpacity(
                    opacity: _emailOpacity,
                    duration: Duration(milliseconds: 500),
                    child: Container(
                      margin: EdgeInsets.only(top: 50, right: 10),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "Enter your Email",
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "First name is required";
                          }
                          return null;
                        },
                        onChanged: (val) {
                          email = val;
                        },
                      ),
                    ),
                  ),


                  AnimatedOpacity(
                    opacity: _buttonsOpacity,
                    duration: Duration(milliseconds: 500),
                  child:
                  Container(
                    height: 50,
                    width: 200,
                    margin: EdgeInsets.only(top: 50),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: MaterialButton(
                        color: Colors.lightBlue,
                        onPressed: () {
                          // Gmail login functionality here
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 10),
                            Text(
                              "Send code to Gmail",
                              style: TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  )
                ],
              )

              )



            ],
          )),
        ),
      ),
    );
  }
}
