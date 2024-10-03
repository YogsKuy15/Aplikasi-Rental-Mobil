import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MailboxScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MailBox'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/logo.png'), // Sesuaikan dengan path logo transparan Anda
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.blue.withOpacity(0.1), BlendMode.dstATop),
                ),
              ),
            ),
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('rental').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text('Tidak ada data penyewaan.'),
                );
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var rental = snapshot.data!.docs[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: ListTile(
                      title: Text(
                        rental['nama'] ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Text('Alamat: ${rental['alamat'] ?? ''}'),
                          Text('Kontak: ${rental['kontak'] ?? ''}'),
                          Text('Metode: ${rental['metode'] ?? ''}'),
                          Text('Status: ${rental['status'] ?? ''}'),
                          Text('Tanggal Mulai: ${rental['tanggalmulai'] ?? ''}'),
                          Text('Tanggal Selesai: ${rental['tanggalselesai'] ?? ''}'),
                          Text('Total Harga: ${rental['totalharga'] ?? ''}'),
                          SizedBox(height: 5),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _confirmDeleteRental(context, rental);
                            },
                          ),
                          if (rental['status'] == 'menunggu pembayaran')
                            IconButton(
                              icon: Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () {
                                _confirmActivateRental(context, rental);
                              },
                            ),
                          if (rental['status'] == 'aktif')
                            IconButton(
                              icon: Icon(Icons.block, color: Colors.orange),
                              onPressed: () {
                                _confirmCancelRental(context, rental);
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteRental(BuildContext context, DocumentSnapshot rental) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Penghapusan'),
          content: Text('Apakah Anda yakin ingin menghapus data penyewaan ini?'),
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
                _deleteRental(context, rental);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteRental(BuildContext context, DocumentSnapshot rental) async {
    try {
      await FirebaseFirestore.instance.collection('rental').doc(rental.id).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data penyewaan berhasil dihapus'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus data penyewaan: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    Navigator.of(context).pop();
  }

  void _confirmActivateRental(BuildContext context, DocumentSnapshot rental) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Mengaktifkan Penyewaan'),
          content: Text('Apakah Anda yakin ingin mengaktifkan penyewaan ini?'),
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
                _activateRental(context, rental);
              },
            ),
          ],
        );
      },
    );
  }

  void _activateRental(BuildContext context, DocumentSnapshot rental) async {
    try {
      await FirebaseFirestore.instance.collection('rental').doc(rental.id).update({
        'status': 'aktif',
      });

      String carId = rental['carId'];
      await FirebaseFirestore.instance.collection('cars').doc(carId).update({
        'status': 'aktif',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Penyewaan berhasil diaktifkan'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengaktifkan penyewaan: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    Navigator.of(context).pop();
  }

  void _confirmCancelRental(BuildContext context, DocumentSnapshot rental) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Membatalkan Penyewaan'),
          content: Text('Apakah Anda yakin ingin membatalkan penyewaan ini?'),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Batalkan'),
              onPressed: () {
                _cancelRental(context, rental);
              },
            ),
          ],
        );
      },
    );
  }

  void _cancelRental(BuildContext context, DocumentSnapshot rental) async {
    try {
      await FirebaseFirestore.instance.collection('rental').doc(rental.id).update({
        'status': 'dibatalkan',
      });

      String carId = rental['carId'];
      await FirebaseFirestore.instance.collection('cars').doc(carId).update({
        'status': 'tersedia',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Penyewaan berhasil dibatalkan'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membatalkan penyewaan: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    Navigator.of(context).pop();
  }
}
