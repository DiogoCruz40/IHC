import 'package:Passenger/pages/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:Passenger/providers/auth_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:Passenger/utils/utils.dart';
import '../widgets/widgets.dart';
import 'pages.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    switch (authProvider.status) {
      case Status.authenticateError:
        Fluttertoast.showToast(msg: "Sign in fail");
        break;
      case Status.authenticateCanceled:
        Fluttertoast.showToast(msg: "Sign in canceled");
        break;
      case Status.authenticated:
        Fluttertoast.showToast(msg: "Sign in success");
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
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
              child: const Text(
                'Passenger',
                style: TextStyle(
                  color: Colors.blue,
                  fontFamily: 'SansBold',
                  fontSize: 36.0,
                ),
              )),
          Container(
            padding: const EdgeInsets.all(10),
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
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
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
                ? const LoadingView()
                : const SizedBox.shrink(),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.blue,
                        elevation: 5,
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'SansBold'),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          bool isSuccess = await authProvider.handleSignIn(
                              email: emailController.text,
                              password: passwordController.text);

                          if (Utilities.isKeyboardShowing()) {
                            Utilities.closeKeyboard(context);
                          }
                          if (isSuccess) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
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
                //sign up screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignupPage(),
                  ),
                );
              },
              child: const Text('Don\'t have an account yet? Sign up',
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
