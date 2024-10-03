import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'admindashboard.dart'; // Import layar DashboardAdmin

class EditMobil extends StatefulWidget {
  final String carId;
  EditMobil({required this.carId});

  @override
  _EditMobilState createState() => _EditMobilState();
}

class _EditMobilState extends State<EditMobil> {
  final TextEditingController _merekController = TextEditingController();
  final TextEditingController _tahunController = TextEditingController();
  final TextEditingController _platNomorController = TextEditingController();
  final TextEditingController _hargaPerHariController = TextEditingController();
  final TextEditingController _warnaController = TextEditingController();

  String _selectedKategori = 'Family Car'; // Default kategori
  String _selectedTransmisi = 'M/T'; // Default transmisi

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadMobilData();
  }

  void _loadMobilData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('cars').doc(widget.carId).get();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    setState(() {
      _merekController.text = data['merek'];
      _selectedKategori = data['kategori'];
      _tahunController.text = data['tahun'].toString();
      _platNomorController.text = data['plat nomor'];
      _hargaPerHariController.text = data['harga_perhari'].toString();
      _warnaController.text = data['warna'];
      _selectedTransmisi = data['transmisi'] ?? 'M/T'; // Set default to 'M/T' if no transmisi field
    });
  }

  Future<void> _updateDataMobil() async {
    try {
      // Update car data in Firestore
      await FirebaseFirestore.instance.collection('cars').doc(widget.carId).update({
        'merek': _merekController.text,
        'kategori': _selectedKategori,
        'tahun': int.tryParse(_tahunController.text) ?? 0,
        'plat nomor': _platNomorController.text,
        'harga_perhari': int.tryParse(_hargaPerHariController.text) ?? 0,
        'warna': _warnaController.text,
        'transmisi': _selectedTransmisi,
      });

      // Show success message
      _showSnackBar(context, 'Data mobil berhasil diperbarui');

      // Clear text controllers and image file state
      _clearControllers();

      // Navigate back to DashboardAdmin screen after editing
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardAdmin()),
      );
    } catch (e) {
      // Show error message if update fails
      _showSnackBar(context, 'Gagal memperbarui data mobil: $e');
    }
  }

  Future<void> _updateGambarMobil() async {
    try {
      String imageUrl = '';

      if (_imageFile != null) {
        // Load current data to get the existing image URL
        DocumentSnapshot doc =
            await FirebaseFirestore.instance.collection('cars').doc(widget.carId).get();
        String? oldImageUrl = doc['gambar'];

        // Check if old image URL exists and delete it
        if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
          await FirebaseStorage.instance.refFromURL(oldImageUrl).delete();
        }

        // Upload new image to Firebase Storage
        final Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('images')
            .child('${DateTime.now()}.jpg');
        final UploadTask uploadTask = storageReference.putFile(_imageFile!);
        await uploadTask.whenComplete(() async {
          imageUrl = await storageReference.getDownloadURL();
        });

        // Update image URL in Firestore
        await FirebaseFirestore.instance.collection('cars').doc(widget.carId).update({
          'gambar': imageUrl,
        });

        // Show success message
        _showSnackBar(context, 'Gambar mobil berhasil diperbarui');

        // Clear image file state
        setState(() {
          _imageFile = null;
        });

        // Navigate back to DashboardAdmin screen after editing
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardAdmin()),
        );
      } else {
        _showSnackBar(context, 'Tidak ada gambar yang dipilih');
      }
    } catch (e) {
      // Show error message if update fails
      _showSnackBar(context, 'Gagal memperbarui gambar mobil: $e');
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
        title: Text('Edit Mobil'),
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
              SizedBox(height: 10),
              Text('Transmisi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Radio<String>(
                    value: 'M/T',
                    groupValue: _selectedTransmisi,
                    onChanged: (value) {
                      setState(() {
                        _selectedTransmisi = value!;
                      });
                    },
                  ),
                  Text('M/T'),
                  Radio<String>(
                    value: 'A/T',
                    groupValue: _selectedTransmisi,
                    onChanged: (value) {
                      setState(() {
                        _selectedTransmisi = value!;
                      });
                    },
                  ),
                  Text('A/T'),
                  Radio<String>(
                    value: 'CVT',
                    groupValue: _selectedTransmisi,
                    onChanged: (value) {
                      setState(() {
                        _selectedTransmisi = value!;
                      });
                    },
                  ),
                  Text('CVT'),
                ],
              ),
              SizedBox(height: 10),
              TextField(
                controller: _tahunController,
                decoration: InputDecoration(labelText: 'Tahun'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _platNomorController,
                decoration: InputDecoration(labelText: 'Plat Nomor'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedKategori,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedKategori = newValue!;
                  });
                },
                items: <String>[
                  'Family Car',
                  'SUV',
                  'Sedan',
                  'Special Car'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Kategori'),
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
                onPressed: () => _updateDataMobil(),
                child: Text('Perbarui Data Mobil'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _updateGambarMobil(),
                child: Text('Perbarui Gambar Mobil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
