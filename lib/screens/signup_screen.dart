import 'package:flutter/material.dart';
import 'package:karoninha/screens/login_screens.dart';
import 'package:karoninha/widgets/form_validator.dart';

import '../widgets/custom_text_field.dart';
import '../widgets/snackbar.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController editingController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  signupFormValidation() {
    final email = editingController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty || phone.isEmpty){
      displaySnackBar("All fields are required.", context);
    } else if(!FormValidator.isValidName(name)){
      displaySnackBar("Name must be at least 4 characters.", context);
    } else if(!FormValidator.isValidPhone(phone)) {
      displaySnackBar("Phone number must be at least 7 digits.", context);
    } else if(!FormValidator.isValidEmail(email)) {
      displaySnackBar("Invalid email format.", context);
    } else if(!FormValidator.isValidPassword(password)) {
      displaySnackBar("Password must be at least 5 characters.", context);
    } else {

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
            "Create a New Account\nas a User",
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
                  controller: nameController,
                  label: "User Name",
                  keyboardType: TextInputType.phone,
                ),

                SizedBox(height: 24),

                CustomTextField(
                    controller: phoneController ,
                    label: "Phone Number",
                    keyboardType: TextInputType.phone
                ),

                SizedBox(height: 24),

                CustomTextField(
                  controller: editingController,
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
                  onPressed: signupFormValidation,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                  ),
                  child: Text(
                    "Create Account",
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
              Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
            },
            child: Text(
              "Already have an account? Login",
            ),
          ),

        ],
      ),
    );
  }
}
