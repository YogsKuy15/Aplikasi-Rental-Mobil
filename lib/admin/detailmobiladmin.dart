import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'edit.dart'; // Pastikan Anda mengimpor EditMobil

class DetailMobilAdmin extends StatelessWidget {
  final String carId;

  DetailMobilAdmin({required this.carId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Mobil'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigasi ke halaman EditMobil
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditMobil(carId: carId),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              _showDeleteDialog(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('cars').doc(carId).get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Data tidak ditemukan'));
          }

          var carData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    image: DecorationImage(
                      image: NetworkImage(carData['gambar']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildDetailItem('Merek', carData['merek']),
                    _buildDetailItem('Transmisi', carData['transmisi']),
                    _buildDetailItem('Harga', 'Rp ${carData['harga_perhari'].toString()}/hari'),
                    _buildDetailItem('Status', carData['status']),
                    _buildDetailItem('Kategori', carData['kategori']),
                    _buildDetailItem('Tahun', carData['tahun'].toString()),
                    _buildDetailItem('Warna', carData['warna']),
                    _buildDetailItem('Plat Nomor', carData['plat nomor']),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            value,
            style: TextStyle(fontSize: 14.0),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Mobil'),
          content: Text('Apakah Anda yakin ingin menghapus mobil ini?'),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Hapus'),
              onPressed: () async {
                await _deleteMobil(context);
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMobil(BuildContext context) async {
    try {
      var docSnapshot = await FirebaseFirestore.instance.collection('cars').doc(carId).get();
      var carData = docSnapshot.data() as Map<String, dynamic>;

      // Hapus gambar dari Firebase Storage
      if (carData['gambar'] != null) {
        await FirebaseStorage.instance.refFromURL(carData['gambar']).delete();
      }

      // Hapus data mobil dari Firestore
      await FirebaseFirestore.instance.collection('cars').doc(carId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mobil berhasil dihapus'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus mobil: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
