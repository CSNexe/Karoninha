import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:karoninha/helper/helper_functions.dart';
import 'package:karoninha/screens/home_screen.dart';
import 'package:karoninha/screens/signup_screen.dart';
import 'package:karoninha/user_info.dart';
import 'package:karoninha/widgets/custom_text_field.dart';
import 'package:karoninha/widgets/form_validator.dart';
import 'package:karoninha/widgets/snackbar.dart';

import '../widgets/loading_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreensState();
}

class _LoginScreensState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  HelperFunctions helperFunctions = HelperFunctions();

  loginFormValidation() {

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if(email.isEmpty || password.isEmpty){
      displaySnackBar("All fields are required.", context);
    } else if (!FormValidator.isValidEmail(email)){
      displaySnackBar("Email format is invalid", context);
    } else if (!FormValidator.isValidPassword(password)){
      displaySnackBar("Password must be at least 6 characters", context);
    } else {
      loginUser();
    }

  }

  loginUser() async {

    showDialog(
        context: context,
        builder: (BuildContext context) => LoadingDialog()
    );

    try {
      final User? fbUser = (await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      ).catchError((onErrorOccurred){
        displaySnackBar(onErrorOccurred.toString(), context);
        Navigator.pop(context);
        return onErrorOccurred;
      })).user;

      helperFunctions.retrieveUserData(context);
      
      displaySnackBar("You are Logged-in Successfully. Hurrah, you can make Trip Requests now. ", context);

      Navigator.push(context, MaterialPageRoute(builder: (c)=> HomeScreen()));
    } on FirebaseAuthException catch (exp){
      displaySnackBar(exp.toString(), context);
      FirebaseAuth.instance.signOut();
      Navigator.pop(context);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Image.asset(
            "assets/images/karonalogo.png",
            width: MediaQuery.of(context).size.width * 0.7,
          ),

          SizedBox(height: 12),

          Text(
            "Login as a User",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontFamily: "MontserratBold",
              color: Colors.white70,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
            child: Column(
              children: [

                CustomTextField(
                  controller: emailController,
                  label: "Email",
                  keyboardType: TextInputType.emailAddress,
                ),

                SizedBox(height: 24),

                CustomTextField(
                  controller: passwordController,
                  label: "Password",
                  isPassword: true,
                ),

                SizedBox(height: 30),

                ElevatedButton(
                  onPressed: loginFormValidation,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                  ),
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "MontserratSemiBold",),
                  ),
                ),

              ],
            ),
          ),

          SizedBox(height: 4),

          TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (c)=> SignupScreen()));
              },
              child: Text(
                "Don't have an account? Sign Up",
              ),
          ),

        ],
      ),
    );
  }
}