import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'formsewa.dart'; // Pastikan Anda mengimpor EditMobil

class DetailMobil extends StatelessWidget {
  final String carId;
  final String? userId; // UserId ditambahkan di sini

  DetailMobil({required this.carId, this.userId}); // UserId diinisialisasi di sini

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Mobil'),
        actions: [
          IconButton(
            icon: Icon(Icons.message),
            onPressed: () {
              // Navigasi ke halaman FormSewa dengan membawa carId dan userId
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormSewa(carId: carId, userId: userId ?? ''), // Pastikan FormSewa menerima userId
                ),
              );
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
}
