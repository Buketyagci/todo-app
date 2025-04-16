import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todoapp/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todoapp/services/auth.dart';

class SignupBody extends StatefulWidget {
  const SignupBody({super.key});

  @override
  State<SignupBody> createState() => _SignupBodyState();
}

class _SignupBodyState extends State<SignupBody> {
  bool passwordVisible = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? errorMessage;
  Future<void> createUser() async {
    try {
      await Auth().createUser(
        name: nameController.text,
        surname: surnameController.text,
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  void _showMessage(String s) {
    Fluttertoast.showToast(
      msg: s,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.teal.shade100,
      textColor: Colors.grey,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [backButton(context), SizedBox(width: 50), title()],
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: textFieldTitle("Name"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: textFormFieldName(),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: textFieldTitle("Surname"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: textFormFieldSurname(),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: textFieldTitle("E-mail"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: textFormFieldEmail(),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: textFieldTitle("Password"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: textFieldPassword(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: signupButton(
              context,
              nameController,
              surnameController,
              emailController,
              passwordController,
            ),
          ),
        ],
      ),
    );
  }

  ElevatedButton signupButton(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController surnameController,
    TextEditingController emailController,
    TextEditingController passwordController,
  ) {
    return ElevatedButton(
      onPressed: () async {
        String name = nameController.text;
        String surname = surnameController.text;
        String email = emailController.text;
        String password = passwordController.text;

        if (name.isEmpty ||
            surname.isEmpty ||
            email.isEmpty ||
            password.isEmpty) {
          _showMessage("Lütfen tüm alanları doldurun.");
          return;
        }
        try {
          await Auth().createUser(
            name: name,
            surname: surname,
            email: email,
            password: password,
          );
          _showMessage("Sign up successfully completed");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } catch (e) {
          _showMessage("There is an error: $e");
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.teal, width: 2),
        ),
        shadowColor: (Colors.teal),
      ),
      child: Text(
        "Sign up",
        style: GoogleFonts.poppins(
          fontSize: 24,
          color: Colors.amber,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  TextField textFieldPassword() {
    return TextField(
      controller: passwordController,
      obscureText: passwordVisible,
      decoration: InputDecoration(
        hintText: "Password",
        hintStyle: GoogleFonts.poppins(
          fontSize: 16,
          color: const Color.fromARGB(255, 84, 82, 82),
        ),
        helper: Text(
          "At least 6 characters",
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.teal),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.teal, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.teal.shade100, width: 3),
        ),
        suffixIcon: IconButton(
          icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              passwordVisible = !passwordVisible;
            });
          },
        ),
      ),
    );
  }

  TextFormField textFormFieldEmail() {
    return TextFormField(
      controller: emailController,
      style: GoogleFonts.poppins(color: Colors.black),
      decoration: InputDecoration(
        labelText: "E-mail",
        hintStyle: GoogleFonts.poppins(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.teal, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.teal.shade100, width: 3),
        ),
      ),
      minLines: 1,
      maxLines: null,
    );
  }

  TextFormField textFormFieldName() {
    return TextFormField(
      controller: nameController,
      style: GoogleFonts.poppins(color: Colors.black),
      decoration: InputDecoration(
        labelText: "Name",
        hintStyle: GoogleFonts.poppins(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.teal, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.teal.shade100, width: 3),
        ),
      ),
      minLines: 1,
      maxLines: null,
    );
  }

  TextFormField textFormFieldSurname() {
    return TextFormField(
      controller: surnameController,
      style: GoogleFonts.poppins(color: Colors.black),
      decoration: InputDecoration(
        labelText: "Surname",
        hintStyle: GoogleFonts.poppins(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.teal, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.teal.shade100, width: 3),
        ),
      ),
      minLines: 1,
      maxLines: null,
    );
  }

  Text textFieldTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.amber,
      ),
    );
  }

  Text title() {
    return Text(
      "Signup Page",
      style: GoogleFonts.poppins(
        color: Colors.teal,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  IconButton backButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      },
      icon: Icon(Icons.arrow_back, color: Colors.teal.shade100, size: 40),
    );
  }
}
