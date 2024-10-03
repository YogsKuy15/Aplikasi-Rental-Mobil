import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManajemenPenyewa extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen Penyewa'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/logo.png'), // Ganti dengan path logo transparan Anda
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(Colors.blue.withOpacity(0.1), BlendMode.dstATop),
          ),
          color: Colors.blue,
        ),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users')
              .where('peran', isEqualTo: 'user') // Menyaring hanya pengguna dengan peran "user"
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
            return ListView(
              padding: EdgeInsets.all(16.0),
              children: snapshot.data!.docs.map((doc) {
                return Card(
                  elevation: 4.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        doc['nama'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doc['email']),
                          Text(doc['kontak']),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _confirmDeleteUser(context, doc);
                            },
                          ),
                          if (doc['status'] == 'aktif')
                            IconButton(
                              icon: Icon(Icons.block, color: Colors.orange),
                              onPressed: () {
                                _confirmDisableUser(context, doc);
                              },
                            ),
                          if (doc['status'] == 'nonaktif')
                            IconButton(
                              icon: Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () {
                                _confirmActivateUser(context, doc);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Penghapusan'),
          content: Text('Apakah Anda yakin ingin menghapus pengguna ini?'),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Hapus'),
              onPressed: () {
                _deleteUser(context, doc);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(BuildContext context, DocumentSnapshot doc) async {
    try {
      // Hapus pengguna dari Firestore
      await FirebaseFirestore.instance.collection('users').doc(doc.id).delete();

      // Hapus pengguna dari Firebase Authentication
      String uid = doc.id;
      User? user = FirebaseAuth.instance.currentUser;
      
      if (user != null && user.uid == uid) {
        await user.delete();
      } else {
        await FirebaseAuth.instance.authStateChanges().listen((User? user) async {
          if (user != null && user.uid == uid) {
            await user.delete();
          }
        });
      }

      // Tampilkan pesan sukses dengan SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pengguna berhasil dihapus'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Tangani kesalahan jika penghapusan gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus pengguna: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    // Tutup dialog konfirmasi
    Navigator.of(context).pop();
  }

  void _confirmDisableUser(BuildContext context, DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Menonaktifkan Akun'),
          content: Text('Apakah Anda yakin ingin menonaktifkan akun pengguna ini?'),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Nonaktifkan'),
              onPressed: () {
                _disableUser(context, doc);
              },
            ),
          ],
        );
      },
    );
  }

  void _disableUser(BuildContext context, DocumentSnapshot doc) async {
    try {
      // Update status pengguna menjadi nonaktif di Firestore
      await FirebaseFirestore.instance.collection('users').doc(doc.id).update({
        'status': 'nonaktif',
      });

      // Tampilkan pesan sukses dengan SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Akun pengguna berhasil dinonaktifkan'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Tangani kesalahan jika nonaktifkan gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menonaktifkan akun pengguna: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    // Tutup dialog konfirmasi
    Navigator.of(context).pop();
  }

  void _confirmActivateUser(BuildContext context, DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Mengaktifkan Akun'),
          content: Text('Apakah Anda yakin ingin mengaktifkan kembali akun pengguna ini?'),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Aktifkan'),
              onPressed: () {
                _activateUser(context, doc);
              },
            ),
          ],
        );
      },
    );
  }

  void _activateUser(BuildContext context, DocumentSnapshot doc) async {
    try {
      // Update status pengguna menjadi aktif di Firestore
      await FirebaseFirestore.instance.collection('users').doc(doc.id).update({
        'status': 'aktif',
      });

      // Tampilkan pesan sukses dengan SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Akun pengguna berhasil diaktifkan kembali'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Tangani kesalahan jika aktivasi gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengaktifkan kembali akun pengguna: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    // Tutup dialog konfirmasi
    Navigator.of(context).pop();
  }
}
