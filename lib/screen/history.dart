import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat'),
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
          stream: FirebaseFirestore.instance.collection('rental').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var rental = snapshot.data!.docs[index];
                return Card(
                  elevation: 3, // Add elevation for a card-like appearance
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: ListTile(
                    title: Text(
                      rental['nama'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        Text('Alamat: ${rental['alamat']}'),
                        Text('Kontak: ${rental['kontak']}'),
                        Text('Metode: ${rental['metode']}'),
                        Text('Status: ${rental['status']}'),
                        Text('Tanggal Mulai: ${rental['tanggalmulai']}'),
                        Text('Tanggal Selesai: ${rental['tanggalselesai']}'),
                        Text('Total Harga: ${rental['totalharga']}'),
                        SizedBox(height: 5),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
