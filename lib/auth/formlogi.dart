import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplikasi_rental_mobil/auth/register.dart'; // Sesuaikan dengan path Anda
import 'package:aplikasi_rental_mobil/admin/admindashboard.dart';
import 'package:aplikasi_rental_mobil/screen/userDashboard.dart'; // Sesuaikan dengan path Anda

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
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
                    'Login',
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
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        border: InputBorder.none,
                        icon: Icon(Icons.email),
                      ),
                      onChanged: (value) {
                        email = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
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
                        hintText: 'Enter your password',
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
                        password = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _errorMessage = '';
                        });
                        try {
                          final user = await _auth.signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );

                          if (user != null) {
                            // Ambil data pengguna dari Firestore
                            DocumentSnapshot userData = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.user!.uid)
                                .get();

                            if (userData.exists) {
                              String role = userData['peran'];
                              bool emailVerified = user.user!.emailVerified;

                              if (role == 'admin') {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => DashboardAdmin()),
                                );
                              } else {
                                // Pemeriksaan email terverifikasi
                                if (!emailVerified) {
                                  setState(() {
                                    _errorMessage = 'Email belum diverifikasi. Silakan verifikasi email Anda.';
                                  });
                                  await _auth.signOut();
                                } else {
                                  // Pemeriksaan status akun
                                  String status = userData['status'];
                                  if (status == 'aktif') {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => DashboardUSer()),
                                    );
                                  } else {
                                    setState(() {
                                      _errorMessage = 'Akun pengguna telah dinonaktifkan.';
                                    });
                                    await _auth.signOut();
                                  }
                                }
                              }
                            } else {
                              setState(() {
                                _errorMessage = 'Data pengguna tidak ditemukan.';
                              });
                            }
                          }
                        } catch (e) {
                          setState(() {
                            if (e is FirebaseAuthException) {
                              switch (e.code) {
                                case 'user-not-found':
                                  _errorMessage = 'Tidak ada pengguna yang ditemukan dengan email tersebut.';
                                  break;
                                case 'wrong-password':
                                  _errorMessage = 'Password yang dimasukkan salah.';
                                  break;
                                case 'invalid-email':
                                  _errorMessage = 'Format email tidak valid.';
                                  break;
                                case 'user-disabled':
                                  _errorMessage = 'Akun pengguna telah dinonaktifkan.';
                                  break;
                                case 'too-many-requests':
                                  _errorMessage = 'Terlalu banyak percobaan masuk. Coba lagi nanti.';
                                  break;
                                default:
                                  _errorMessage = 'Login gagal. Silakan coba lagi nanti.';
                                  break;
                              }
                              // Tambahan untuk menampilkan pesan jika email belum diverifikasi
                              if (e.code == 'user-not-found' && !_auth.currentUser!.emailVerified) {
                                _errorMessage = 'Email belum diverifikasi. Silakan verifikasi email Anda.';
                              }
                            } else {
                              _errorMessage = 'Terjadi kesalahan. Silakan coba lagi nanti.';
                            }
                          });
                        }
                      }
                    },
                    child: Text('Login'),
                  ),
                  SizedBox(height: 16),
                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      _showForgotPasswordDialog();
                    },
                    child: Text("Forgot Password?"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                      );
                    },
                    child: Text("Belum punya akun? Sign Up"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String resetEmail = '';

        return AlertDialog(
          title: Text('Forgot Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Masukkan email Anda untuk reset password:'),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Email',
                ),
                onChanged: (value) {
                  resetEmail = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Reset Password'),
              onPressed: () async {
                try {
                  await _auth.sendPasswordResetEmail(email: resetEmail);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Email untuk reset password telah dikirim.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal mengirim email reset password: $e'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
