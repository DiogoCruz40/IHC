import 'package:Passenger/services/auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String error = '';

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
              child: Text(
                'Passenger',
                style: TextStyle(
                  color: Colors.blue,
                  fontFamily: 'SansBold',
                  fontSize: 36.0,
                ),
              )),
          Container(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
            child: TextField(
              obscureText: true,
              controller: passwordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.blue,
                        elevation: 5,
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'SansBold'),
                      ),
                      onPressed: () async {
                        dynamic result = await _auth.signInUsingEmailPassword(
                            email: emailController.text,
                            password: passwordController.text);
                        if (result == null) {
                          print(emailController.text);
                          print(passwordController.text);
                        }
                      },
                    )),
              ),
            ],
          ),
          TextButton(
            child: Text(
              'Does not have account? Register now!',
              style: TextStyle(
                  color: Colors.blue,
                  fontFamily: 'SansRegular',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600),
            ),
            onPressed: () async {
              //signup screen
            },
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: TextButton(
              onPressed: () {
                //forgot password screen
              },
              child: Text('Forgot Password',
                  style: TextStyle(
                      color: Colors.blue,
                      fontFamily: 'SansRegular',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    ));
  }
}
