import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todoapp/screens/entry/entry.dart';
import 'package:todoapp/screens/signup/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:todoapp/services/auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Login Page",
      theme: ThemeData(
        primarySwatch: Colors.teal,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool passwordVisible = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? errorMessage;
  String? username = "";

  Future<void> signIn() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        errorMessage = "E-posta veya şifre boş olamaz!";
      });
      return; 
    }

    print('E-posta: ${emailController.text}');
    print('Şifre: ${passwordController.text}');
    try {
      await Auth().signIn(
        email: emailController.text,
        password: passwordController.text,
      );
      
      Navigator.push(context, MaterialPageRoute(builder: (context) => Entry()));
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Login Screen",
          style: GoogleFonts.poppins(
            color: Colors.teal,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "Input e-mail",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: textFormFieldEmail(),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "Input password",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: textFieldPassword(),
          ),
          errorMessage != null ? Text(errorMessage!) : SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: loginButton(
              context
            ),
          ),
          Expanded(child: SizedBox(height: 200)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("You don't have an account?"),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },
                child: Text(
                  "Sign up",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade200,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ElevatedButton loginButton(BuildContext context) {
    final Auth authService = Auth();

    return ElevatedButton(
      onPressed: () async {
        final email = emailController.text.trim();
        final password = passwordController.text.trim();

        if (email.isEmpty || password.isEmpty) {
          setState(() {
            errorMessage = "E-posta veya şifre boş olamaz!";
          });
          return;
        }

        try {
          await authService.signIn(email: email, password: password);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Entry()),
          );
        } catch (e) {
          print("Giriş hatası buton: $e");
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Giriş başarısız: $e")));
        }
      },
      child: Icon(Icons.arrow_forward, color: Colors.teal.shade100, size: 50),
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
      minLines: 2,
      maxLines: null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'E-posta boş olamaz!';
        }
        return null;
      },
    );
  }

  TextFormField textFieldPassword() {
    return TextFormField(
      controller: passwordController,
      obscureText: passwordVisible,
      decoration: InputDecoration(
        hintText: "Password",
        hintStyle: GoogleFonts.poppins(
          fontSize: 16,
          color: const Color.fromARGB(255, 84, 82, 82),
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Şifre boş olamaz!';
        } else if (value.length < 6) {
          return 'Şifre en az 6 karakter olmalıdır!';
        }
        return null;
      },
    );
  }
}
