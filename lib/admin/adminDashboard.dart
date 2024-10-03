import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'manajemen_mobil.dart';
import 'manajemen_penyewa.dart';
import 'Mailbox.dart';
import 'listviewadmin.dart'; // Mengimport halaman ListViewAdmin
import 'package:aplikasi_rental_mobil/auth/formlogi.dart';

class DashboardAdmin extends StatefulWidget {
  @override
  _DashboardAdminState createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  String adminName = '';
  String adminRole = '';

  @override
  void initState() {
    super.initState();
    _getAdminData();
  }

  void _getAdminData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot adminData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        adminName = adminData['nama'] ?? 'Admin';
        adminRole = adminData['peran'] ?? 'Peran';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Admin'),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.indigo[900],
          child: Column(
            children: <Widget>[
              DrawerHeader(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[300],  // Warna latar belakang avatar
                      child: Icon(
                      Icons.person,  // Ganti dengan ikon yang Anda inginkan, misalnya Icons.person untuk ikon orang
                      size: 60,
                      color: Colors.blueAccent,  // Warna ikon
                      ),
                    ),
                      SizedBox(height: 10),
                      SizedBox(height: 5),
                      Text(
                        adminRole,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
              ),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    _createDrawerItem(
                      icon: Icons.dashboard,
                      text: 'Dashboard',
                      onTap: () {
                        Navigator.pop(context); // Menutup drawer
                      },
                    ),
                    _createDrawerItem(
                      icon: Icons.car_rental,
                      text: 'Manajemen Mobil',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ManajemenMobil()),
                        );
                      },
                    ),
                    _createDrawerItem(
                      icon: Icons.people,
                      text: 'Manajemen Penyewa',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ManajemenPenyewa()),
                        );
                      },
                    ),
                    _createDrawerItem(
                      icon: Icons.mail,
                      text: 'MailBox',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MailboxScreen()),
                        );
                      },
                    ),
                    _createDrawerItem(
                      icon: Icons.logout,
                      text: 'Logout',
                      onTap: () {
                        _logout(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: Colors.blue[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: MenuMobil(), // Memanggil ListViewAdmin di sini
            ),
          ],
        ),
      ),
    );
  }

  Widget _createDrawerItem({
    required IconData icon,
    required String text,
    GestureTapCallback? onTap,
  }) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon, color: Colors.white),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/'); // Ganti dengan rute halaman login yang benar
    } catch (e) {
      print('Error signing out: $e');
      // Handle error signing out
    }
  }
}
