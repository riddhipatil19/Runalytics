import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:runn_track/api/api_auth.dart';
import 'package:runn_track/pages/home.dart';
import 'package:runn_track/styles/app_styles.dart';
import 'package:runn_track/util/shared_pref_helper.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool isPasswordVisible = false;
  bool isLoading = false;

  ApiAuth auth = ApiAuth();

  void signup() async {
    setState(() {
      isLoading = true;
    });
    final response = await auth.signUp(
        name: name.text, email: email.text, password: password.text);

    if (response['status'] == 200) {
      Fluttertoast.showToast(
          msg: response['message'] + '\nPlease login',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      Fluttertoast.showToast(
          msg: response['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Sign Up',
                  textAlign: TextAlign.center,
                  style: AppStyles.heading.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 32),

                // Name Field
                TextField(
                  controller: name,
                  keyboardType: TextInputType.name,
                  decoration: AppStyles.inputDecoration('Name'),
                  cursorColor: Colors.blue,
                ),
                const SizedBox(height: 20),

                // Email Field
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: AppStyles.inputDecoration('Email'),
                  cursorColor: Colors.blue,
                ),
                const SizedBox(height: 20),

                // Password Field
                TextField(
                  controller: password,
                  obscureText: !isPasswordVisible,
                  cursorColor: Colors.blue,
                  decoration: AppStyles.inputDecoration('Password').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Sign Up Button
                ElevatedButton(
                  onPressed: () {
                    if (name.text.trim().isEmpty ||
                        email.text.trim().isEmpty ||
                        password.text.trim().isEmpty) {
                      Fluttertoast.showToast(
                        msg: "Please fill in all fields",
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        fontSize: 16.0,
                      );
                    } else {
                      signup();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
