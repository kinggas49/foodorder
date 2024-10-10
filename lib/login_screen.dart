import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'admin_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  // Sign in with Email and Password
  Future<void> _signInWithEmailAndPassword() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful')),
      );
      Navigator.pushReplacementNamed(context, '/menu');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Username atau Password salah',
            style: TextStyle(color: Colors.brown),
          ),
          backgroundColor: Color.fromARGB(255, 255, 224, 178),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.brown),
          ),
        ),
      );
    }
  }
  Future<void> _signInWithGoogle() async {
    try {
      // Start the sign-in process with Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return;
      }

      // Get the authentication object for the Google user
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create an AuthCredential using the accessToken and idToken
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      await _auth.signInWithCredential(credential);

      // If successful, show the snack bar and navigate to the next screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Google Sign-In Successful',
            style: TextStyle(color: Colors.brown),
          ),
          backgroundColor: Color.fromARGB(255, 255, 224, 178),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.brown),
          ),
        ),
      );
      Navigator.pushReplacementNamed(context, '/menu');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Google Sign-In Failed: ${e.toString()}',
            style: const TextStyle(color: Colors.brown),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 224, 178),
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.brown),
          ),
        ),
      );
    }
  }

  Future<void> _signInAsAdmin() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: 'adamdaud69@gmail.com',
        password: '123456',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Admin Login Successful',
            style: TextStyle(color: Colors.brown),
          ),
          backgroundColor: Color.fromARGB(255, 255, 224, 178),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.brown),
          ),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Username atau Password salah: ${e.toString()}',
            style: const TextStyle(color: Colors.brown),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 224, 178),
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.brown),
          ),
        ),
      );
    }
  }

  // Sign in method selector
  void _signIn() {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username == 'admin' && password == '123') {
      _signInAsAdmin();
    } else {
      _signInWithEmailAndPassword();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipPath(
              clipper: CurvedClipper(),
              child: Container(
                height: size.height * 0.35,
                color: const Color(0xFFF5D59D),
                child: Center(
                  child: Image.asset(
                    'assets/logo.png', // Replace with your logo asset path
                    height: size.height * 0.15,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.02),
                  _buildTextField(
                    controller: _usernameController,
                    icon: Icons.person,
                    label: 'Username',
                    obscureText: false,
                  ),
                  SizedBox(height: size.height * 0.02),
                  _buildTextField(
                    controller: _passwordController,
                    icon: Icons.lock,
                    label: 'Password',
                    obscureText: true,
                  ),
                  SizedBox(height: size.height * 0.04),
                  _buildSignInButton(size),
                  SizedBox(height: size.height * 0.02),
                  _buildOrDivider(size),
                  SizedBox(height: size.height * 0.02),
                  _buildGoogleSignInButton(size),
                  SizedBox(height: size.height * 0.02),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required bool obscureText,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color.fromARGB(123, 89, 52, 0)),
        labelText: label,
        labelStyle: const TextStyle(color: Color.fromARGB(123, 89, 52, 0)),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(123, 89, 52, 0)),
        ),
      ),
      obscureText: obscureText,
    );
  }

  Widget _buildSignInButton(Size size) {
    return ElevatedButton(
      onPressed: _signIn,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(245, 213, 157, 1), // background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.2,
          vertical: size.height * 0.02,
        ),
      ),
      child: const Text(
        'Sign in',
        style: TextStyle(color: Color.fromARGB(123, 89, 52, 0)),
      ),
    );
  }

  Widget _buildOrDivider(Size size) {
    return Row(
      children: [
        const Expanded(
          child: Divider(thickness: 1.0),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
          child: const Text('or'),
        ),
        const Expanded(
          child: Divider(thickness: 1.0),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton(Size size) {
    return ElevatedButton.icon(
      onPressed: _signInWithGoogle,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF5D59D), // background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.1,
          vertical: size.height * 0.02,
        ),
      ),
      icon: SizedBox(
        width: size.width * 0.06, // adjust the size as needed
        height: size.height * 0.035, // adjust the size as needed
        child: Image.asset(
          'assets/google.png',
          color: const Color.fromARGB(123, 89, 52, 0), // replace with your logo asset path
        ),
      ),
      label: const Text(
        'Sign in with Google',
        style: TextStyle(color: Color.fromARGB(123, 89, 52, 0)),
      ),
    );
  }
}

class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 100);
    var firstControlPoint = Offset(size.width / 2, size.height);
    var firstEndPoint = Offset(size.width, size.height - 100);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
