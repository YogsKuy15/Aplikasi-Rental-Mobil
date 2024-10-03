import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'admindashboard.dart'; // Import layar DashboardAdmin

class ManajemenMobil extends StatefulWidget {
  @override
  _ManajemenMobilState createState() => _ManajemenMobilState();
}

class _ManajemenMobilState extends State<ManajemenMobil> {
  final TextEditingController _merekController = TextEditingController();
  final TextEditingController _tahunController = TextEditingController();
  final TextEditingController _platNomorController = TextEditingController();
  final TextEditingController _hargaPerHariController = TextEditingController();
  final TextEditingController _warnaController = TextEditingController();

  String _selectedKategori = 'Family Car'; // Default kategori
  String _selectedTransmisi = 'M/T'; // Default transmisi

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  void _tambahMobil(BuildContext context) async {
    try {
      String imageUrl = '';

      if (_imageFile != null) {
        // Upload gambar ke Firebase Storage
        final Reference storageReference = FirebaseStorage.instance.ref().child('images').child('${DateTime.now()}.jpg');
        final UploadTask uploadTask = storageReference.putFile(_imageFile!);
        await uploadTask.whenComplete(() async {
          imageUrl = await storageReference.getDownloadURL();
        });
      }

      // Simpan data mobil ke Firestore
      await FirebaseFirestore.instance.collection('cars').add({
        'merek': _merekController.text,
        'kategori': _selectedKategori,
        'transmisi': _selectedTransmisi,
        'tahun': int.tryParse(_tahunController.text) ?? 0, // Menggunakan int.tryParse untuk menghindari kesalahan jika input tidak valid
        'plat nomor': _platNomorController.text,
        'harga_perhari': int.tryParse(_hargaPerHariController.text) ?? 0, // Menggunakan int.tryParse untuk menghindari kesalahan jika input tidak valid
        'warna': _warnaController.text,
        'gambar': imageUrl, // URL gambar yang diunggah
        'status': 'tersedia',
      });

      _showSnackBar(context, 'Mobil berhasil ditambahkan');
      _clearControllers();
      setState(() {
        _imageFile = null;
      });

      // Navigate to DashboardAdmin screen setelah menambahkan mobil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardAdmin()),
      );

    } catch (e) {
      _showSnackBar(context, 'Gagal menambahkan mobil: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearControllers() {
    _merekController.clear();
    _tahunController.clear();
    _platNomorController.clear();
    _hargaPerHariController.clear();
    _warnaController.clear();
  }

  Future<void> _getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen Mobil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _merekController,
                decoration: InputDecoration(labelText: 'Merek'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedKategori,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedKategori = newValue!;
                  });
                },
                items: <String>['Family Car', 'SUV', 'Sedan', 'Special Car']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Kategori'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedTransmisi,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTransmisi = newValue!;
                  });
                },
                items: <String>['M/T', 'A/T', 'CVT']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Transmisi'),
              ),
              TextField(
                controller: _tahunController,
                decoration: InputDecoration(labelText: 'Tahun'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _platNomorController,
                decoration: InputDecoration(labelText: 'Plat Nomor'),
              ),
              TextField(
                controller: _hargaPerHariController,
                decoration: InputDecoration(labelText: 'Harga Per Hari'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _warnaController,
                decoration: InputDecoration(labelText: 'Warna'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getImage,
                child: Text('Pilih Gambar'),
              ),
              SizedBox(height: 10),
              _imageFile != null
                  ? Image.file(_imageFile!, height: 150)
                  : SizedBox.shrink(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _tambahMobil(context),
                child: Text('Tambah Mobil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
