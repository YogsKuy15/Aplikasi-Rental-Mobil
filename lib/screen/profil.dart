import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Pengguna'),
      ),
      body: Center(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text('Terjadi kesalahan: ${snapshot.error}');
            }

            if (snapshot.hasData && snapshot.data!.exists) {
              // Pastikan ada data dan dokumen ada
              Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;

              // Gunakan nilai default jika field null
              String displayName = userData['nama'] ?? 'Nama tidak tersedia';
              String email = userData['email'] ?? 'Email tidak tersedia';
              String contact = userData['kontak'] ?? 'Kontak tidak tersedia';
              String role = userData['peran'] ?? 'Peran tidak tersedia';

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Profil Pengguna',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildProfileItem('Nama Pengguna', displayName),
                    _buildProfileItem('Email', email),
                    _buildProfileItem('Kontak', contact),
                    _buildProfileItem('Peran', role),
                  ],
                ),
              );
            } else {
              return Text('Data pengguna tidak ditemukan');
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfileItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$title: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
