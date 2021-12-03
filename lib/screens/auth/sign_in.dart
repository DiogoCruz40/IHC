import 'package:Passenger/screens/auth/register.dart';
import 'package:Passenger/services/auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

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
            child: TextFormField(
              validator: (email) {
                if (email == null ||
                    email.isEmpty ||
                    !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(email)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              controller: emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
            child: TextFormField(
              obscureText: true,
              validator: (password) {
                if (password == null ||
                    password.isEmpty ||
                    password.length < 6) {
                  return 'Please enter a password with at least 6 characters';
                }
                return null;
              },
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
                        if (_formKey.currentState!.validate()) {
                          dynamic result = await _auth.signInUsingEmailPassword(
                              email: emailController.text,
                              password: passwordController.text);
                          if (result == null) {
                            print('user empty');
                          }
                          print(result.email);
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Register()),
              );
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
