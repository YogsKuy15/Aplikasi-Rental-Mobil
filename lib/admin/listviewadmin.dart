import 'package:aplikasi_rental_mobil/admin/detailmobiladmin.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aplikasi_rental_mobil/admin/Edit.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: MenuMobil(),
  ));
}

class MenuMobil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0, // Menghilangkan tinggi toolbar
      ),
      body: MobilListView(),
    );
  }
}

class MobilListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackgroundGradient(),
        StreamBuilder(
          stream: FirebaseFirestore.instance.collection('cars').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            final cars = snapshot.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailMobilAdmin(
                            carId: car.id,
                          ),
                        ),
                      );
                    },
                    child: CarVerticalCard(
                      car: {
                        'imageUrl': car['gambar'],
                        'name': car['merek'],
                        'transmisi': car['transmisi'],
                        'price': formatCurrency(car['harga_perhari']),
                        'status': car['status'],
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
        Center(
          child: Opacity(
            opacity: 0.1,
            child: Image.asset(
              'assets/images/logo.png', // Sesuaikan dengan path logo Anda
              width: 200,
              height: 200,
            ),
          ),
        ),
      ],
    );
  }

  String formatCurrency(int price) {
    final formatter = NumberFormat("#,###", "id_ID");
    return 'Rp. ${formatter.format(price)}/hari';
  }
}

class BackgroundGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.indigo.shade900, Colors.blue.shade200],
        ),
      ),
    );
  }
}

class CarVerticalCard extends StatelessWidget {
  final Map<String, dynamic> car;

  CarVerticalCard({required this.car});

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.green; // Default color for 'tersedia'
    String statusText = 'Tersedia';

    if (car['status'] == 'disewa') {
      statusColor = Colors.red; // Change color to red if status is 'disewa'
      statusText = 'Disewa';
    } else if (car['status'] == 'pending') {
      statusColor = Colors.yellow; // Change color to yellow if status is 'pending'
      statusText = 'Pending';
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Colors.grey[200], // Background color
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.grey[200], // Background color
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(
                  car['imageUrl'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              car['name'],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 5),
            Text(
              'Transmisi: ${car['transmisi']}',
              style: TextStyle(fontSize: 14, color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 5),
            Text(
              'Harian: ${car['price']}',
              style: TextStyle(fontSize: 14, color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Text(
                  'Status: ',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  statusText,
                  style: TextStyle(fontSize: 14, color: statusColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}