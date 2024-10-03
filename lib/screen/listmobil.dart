import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detailmobil.dart'; // Import kelas DetailMobil
import 'package:intl/intl.dart';

void main() => runApp(MaterialApp(
      home: CarGridScreen(),
    ));

class CarGridScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          image: DecorationImage(
            opacity: 0.1,
            image: AssetImage('assets/images/logo.png'), // Ganti dengan path logo transparan Anda
            fit: BoxFit.contain,
          ),
        ),
        child: FutureBuilder<User?>(
          future: _getCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('User not logged in'));
            } else {
              String userId = snapshot.data!.uid; // Ambil UID dari user yang sedang login
              return _buildCarGrid(context, userId);
            }
          },
        ),
      ),
    );
  }

  Future<User?> _getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Widget _buildCarGrid(BuildContext context, String userId) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('cars').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No cars available'));
        }

        return GridView.builder(
          padding: EdgeInsets.all(16.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2 / 3,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var car = snapshot.data!.docs[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailMobil(carId: car.id, userId: userId),
                  ),
                );
              },
              child: CarCard(
                imageUrl: car['gambar'],
                name: car['merek'],
                price: car['harga_perhari'],
                transmisi: car['transmisi'] ?? '', // Periksa jika field ada
                status: car['status'] ?? '', // Periksa jika field ada
              ),
            );
          },
        );
      },
    );
  }
}

class CarCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final int price;
  final String transmisi;
  final String status;

  const CarCard({
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.transmisi,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    String formattedPrice = formatCurrency(price); // Memformat harga ke dalam format mata uang
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade500,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Transmisi: $transmisi',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white70,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Status: $status',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white70,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              formattedPrice,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white70,
              ),
            ),
          ),
          SizedBox(height: 8.0),
        ],
      ),
    );
  }

  String formatCurrency(int price) {
    final formatter = NumberFormat("#,###", "id_ID");
    return 'Rp. ${formatter.format(price)}/hari';
  }
}
