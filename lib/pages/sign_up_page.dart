import 'package:flutter/material.dart';
import 'package:Passenger/constants/app_constants.dart';
import 'package:Passenger/constants/color_constants.dart';
import 'package:Passenger/providers/auth_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:Passenger/utils/utils.dart';
import '../widgets/widgets.dart';
import 'pages.dart';

class SignupPage extends StatefulWidget {
  SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    switch (authProvider.status) {
      case Status.authenticateError:
        Fluttertoast.showToast(msg: "Account already exists");
        break;
      case Status.authenticateCanceled:
        Fluttertoast.showToast(msg: "Sign up canceled");
        break;
      case Status.authenticated:
        Fluttertoast.showToast(msg: "Sign up success");
        break;
      default:
        break;
    }
    return Scaffold(
        body: Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
              child: const Text(
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
              validator: (username) {
                if (username == null || username.isEmpty) {
                  return 'Please enter a valid username';
                }
                return null;
              },
              controller: usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Username',
              ),
            ),
          ),
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
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
          ),
          Positioned(
            child: authProvider.status == Status.authenticating
                ? LoadingView()
                : SizedBox.shrink(),
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
                      child: const Text(
                        'Register',
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'SansBold'),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          bool isSuccess = await authProvider.handleSignup(
                              username: usernameController.text,
                              email: emailController.text,
                              password: passwordController.text);

                          if (Utilities.isKeyboardShowing()) {
                            Utilities.closeKeyboard(context);
                          }
                          if (isSuccess) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            );
                          }
                        }
                      },
                    )),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: TextButton(
              onPressed: () {
                //sign in screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              child: const Text('Already have an account yet? Sign in',
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
