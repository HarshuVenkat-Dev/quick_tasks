import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  //final TextEditingController emailController = TextEditingController();

  Future<void> signup(BuildContext context) async {
    final user = ParseUser(usernameController.text, passwordController.text,
        usernameController.text);
    var response = await user.signUp();

    print("ParseUser: ${user.toString()}");

    if (response.success) {
      Navigator.pushNamed(context, '/');
    } else {
      print('Error: ${response.error?.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SignUp')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextFormField(
              controller: confirmPasswordController,
              decoration: InputDecoration(labelText: 'ConfirmPassword'),
              obscureText: true,
            ),
            // TextFormField(
            //   controller: emailController,
            //   decoration: InputDecoration(labelText: 'Email'),
            // ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => signup(context),
              child: Text('Sign Up'),
            ),
            // TextButton(
            //   onPressed: () {
            //     Navigator.pushNamed(context, '/signup');
            //   },
            //   child: Text('Create an account'),
            // ),
          ],
        ),
      ),
    );
  }
}
