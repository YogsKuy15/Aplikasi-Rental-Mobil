import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplikasi_rental_mobil/auth/formlogi.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String email = '';
  String password = '';
  String nama = '';
  String kontak = '';
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 200,
                    width: 200,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Daftar',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.blue[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Masukkan nama anda',
                        border: InputBorder.none,
                        icon: Icon(Icons.person),
                      ),
                      onChanged: (value) {
                        setState(() {
                          nama = value.trim();
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan nama anda';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.blue[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Masukkan email anda',
                        border: InputBorder.none,
                        icon: Icon(Icons.email),
                      ),
                      onChanged: (value) {
                        setState(() {
                          email = value.trim();
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan email anda';
                        }
                        bool emailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
                        if (!emailValid) {
                          return 'Email tidak valid';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.blue[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Masukkan kontak anda',
                        border: InputBorder.none,
                        icon: Icon(Icons.phone),
                      ),
                      onChanged: (value) {
                        setState(() {
                          kontak = value.trim();
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan kontak anda';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.blue[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextFormField(
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: 'Masukkan kata sandi anda',
                        border: InputBorder.none,
                        icon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          password = value.trim();
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan kata sandi anda';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final newUser = await _auth.createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          if (newUser != null) {
                            await _firestore.collection('users').doc(newUser.user!.uid).set({
                              'nama': nama,
                              'email': email,
                              'kontak': kontak,
                              'peran': 'user',
                              'status': 'aktif', // Set status pengguna sebagai aktif
                            });

                            // Kirim verifikasi email
                            await newUser.user!.sendEmailVerification();

                            setState(() {
                              email = '';
                              password = '';
                              nama = '';
                              kontak = '';
                              _errorMessage = '';
                            });

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Verifikasi Email'),
                                  content: Text('Silakan periksa email Anda untuk verifikasi akun.'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => LoginScreen()),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        } catch (e) {
                          print(e);
                          String errorMessage = 'Terjadi kesalahan.';

                          if (e is FirebaseAuthException) {
                            switch (e.code) {
                              case 'email-already-in-use':
                                errorMessage = 'Email sudah digunakan.';
                                break;
                              case 'invalid-email':
                                errorMessage = 'Format email tidak valid.';
                                break;
                              case 'weak-password':
                                errorMessage = 'Password terlalu lemah.';
                                break;
                              default:
                                errorMessage = 'Terjadi kesalahan.';
                                break;
                            }
                          }
                          setState(() {
                            _errorMessage = errorMessage;
                          });
                        }
                      }
                    },
                    child: Text('Daftar'),
                  ),
                  SizedBox(height: 16),
                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
