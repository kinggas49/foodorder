import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'login_screen.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String _category = 'Beverages';

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadData() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select an image')),
      );
      return;
    }

    try {
      String imageUrl = await _uploadImage(_imageFile!);
      await FirebaseFirestore.instance.collection(_category).add({
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'image': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Menu item added successfully')),
      );
      _nameController.clear();
      _priceController.clear();
      setState(() {
        _imageFile = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add menu item: $e')),
      );
    }
  }

  Future<String> _uploadImage(File image) async {
    final storageRef = FirebaseStorage.instance.ref().child('menu_images').child(DateTime.now().toString());
    final uploadTask = storageRef.putFile(image);
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: Text('Admin Page'),
        backgroundColor: Colors.orange.shade100,
        elevation: 0,
      ),
      drawer: Drawer(
          child: Container(
            color: Color.fromARGB(255, 245, 213, 157),
            child: ListView(
              children: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.25,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.brown),
                        color: Color.fromARGB(255, 255, 255, 255),  // Set background color if needed
                        borderRadius: BorderRadius.circular(30),  // Set border radius if needed
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,  // Adjust the size of the CircleAvatar if needed
                              backgroundImage: NetworkImage(FirebaseAuth.instance.currentUser?.photoURL ?? "default_image_placeholder"),
                            ),
                            SizedBox(height: 10),  // Adds space between the avatar and text
                            Text(
                              FirebaseAuth.instance.currentUser?.displayName ?? "Admin",
                              style: TextStyle(color: Color.fromARGB(255, 123, 89, 52), fontSize: 20),
                            ),
                            Text(
                              FirebaseAuth.instance.currentUser?.email ?? "",
                              style: TextStyle(color: Color.fromARGB(255, 123, 89, 52), fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ),
                _buildDrawerItem(context, Icons.history, "Order Masuk", '/admin_order_page'),
                _buildDrawerItem(context, Icons.logout, "Sign Out", '', signOut: true),
              ],
            ),
          ),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Product',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Harga',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              onChanged: (String? newValue) {
                setState(() {
                  _category = newValue!;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              items: <String>['Beverages', 'Meals']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            _imageFile == null
                ? Text('No image selected.')
                : Image.file(_imageFile!, height: 150),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Foto Produk'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade100,
                foregroundColor: Colors.brown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadData,
              child: Text('Tambahkan Menu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade100,
                foregroundColor: Colors.brown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String route, {bool signOut = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border : Border.all(color: Colors.brown, width: 1)
        ),
        child: ListTile(
          leading: Icon(icon, color: Color.fromARGB(255, 123, 89, 52)),
          title: Text(
            title,
            style: const TextStyle(
              color: Color.fromARGB(255, 123, 89, 52),
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () async {
            if (signOut) {
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            } else {
              Navigator.pushNamed(context, route);
            }
          },
        ),
      ),
    );
  }
}
