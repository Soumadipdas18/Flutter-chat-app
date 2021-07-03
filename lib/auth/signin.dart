import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/auth/signup.dart';
import 'package:location/auth/forgetpassword.dart';
import 'package:location/constants/constants.dart';
import 'package:location/page/home.dart';

class Signinpage extends StatefulWidget {
  const Signinpage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _SigninpageState createState() => _SigninpageState();
}

class _SigninpageState extends State<Signinpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(widget.title)), body: Forms());
  }
}

class Forms extends StatefulWidget {
  const Forms({Key? key}) : super(key: key);

  @override
  _FormsState createState() => _FormsState();
}

class _FormsState extends State<Forms> {
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  bool isloading = false;
  final keys = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return isloading
        ? Container(
            child: Center(child: CircularProgressIndicator()),
          )
        : Form(
            key: keys,
            child: Container(
              padding: EdgeInsets.all(15.0),
              child: (Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                        hintText: "Enter your email",
                        labelText: "Email",
                        icon: Icon(Icons.email)),
                    validator: (value) {
                      return RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value!)
                          ? null
                          : "Please Enter Correct Email";
                    },
                    controller: emailEditingController,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        hintText: "Enter your password",
                        labelText: "Password",
                        icon: Icon(Icons.lock)),
                    validator: (value) {
                      return value!.length > 6
                          ? null
                          : "Enter Password 6+ characters";
                    },
                    controller: passwordEditingController,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Forgotpassword()));
                    },
                    child: Container(
                        child: Text(
                      "Forgot Password?",
                    )),
                  ),
                  ElevatedButton(
                      child: Text("Log In"),
                      // splashColor: Colors.red,
                      onPressed: () {
                        signIn();
                      }),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(SIGN_UP);
                    },
                    child: Container(
                        child: Text(
                      "Not yet registered? Register now",
                    )),
                  ),
                ],
              )),
            ));
  }

  signIn() async {
    if (keys.currentState!.validate()) {
      setState(() {
        isloading = true;
      });
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: emailEditingController.text,
                password: passwordEditingController.text);
        setState(() {
          isloading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Logged in successfully')));
        Navigator.of(context).pushReplacementNamed(HOME_SCREEN);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No user found for that email.')));
          setState(() {
            isloading = false;
          });
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Wrong password provided for that user.')));
          setState(() {
            isloading = false;
          });
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error $e')));
          setState(() {
            isloading = false;
          });
        }
      } catch (e) {
        setState(() {
          isloading = false;
        });
        print(e);
      }
    }
  }
}
