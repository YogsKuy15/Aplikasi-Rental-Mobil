import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormSewa extends StatefulWidget {
  final String carId;
  final String userId;

  FormSewa({required this.carId, required this.userId});

  @override
  _FormSewaState createState() => _FormSewaState();
}

class _FormSewaState extends State<FormSewa> {
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk mengambil nilai dari TextFormField
  final TextEditingController _tanggalMulaiController = TextEditingController();
  final TextEditingController _tanggalSelesaiController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _kontakController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();

  // Variabel untuk menyimpan pilihan metode pembayaran
  String _metodePembayaran = 'Tunai'; // Default pilihan

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Sewa Mobil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                initialValue: widget.userId, // Mengambil userID dari props
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'User ID',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'User ID tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              GestureDetector(
                onTap: _selectDateRange,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _tanggalMulaiController,
                    decoration: InputDecoration(
                      labelText: 'Tanggal Mulai (dd/MM/yyyy)',
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tanggal Mulai tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              GestureDetector(
                onTap: _selectDateRange,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _tanggalSelesaiController,
                    decoration: InputDecoration(
                      labelText: 'Tanggal Selesai (dd/MM/yyyy)',
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tanggal Selesai tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _alamatController,
                decoration: InputDecoration(
                  labelText: 'Alamat',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _kontakController,
                decoration: InputDecoration(
                  labelText: 'Kontak',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kontak tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              // Radio button untuk pilihan metode pembayaran
              ListTile(
                title: Text('Tunai'),
                leading: Radio(
                  value: 'Tunai',
                  groupValue: _metodePembayaran,
                  onChanged: (value) {
                    setState(() {
                      _metodePembayaran = value.toString();
                    });
                  },
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Proses submit form jika valid
                    simpanDataSewa();
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null && picked.start != null && picked.end != null) {
      setState(() {
        _startDate = picked.start!;
        _endDate = picked.end!;
        _tanggalMulaiController.text = DateFormat('dd/MM/yyyy').format(_startDate!);
        _tanggalSelesaiController.text = DateFormat('dd/MM/yyyy').format(_endDate!);
      });
    }
  }

  void simpanDataSewa() async {
    // Mengambil UID pengguna yang sedang login dari Firestore
    String userId = widget.userId;

    // Mengambil data mobil berdasarkan carId dari Firestore
    DocumentSnapshot carSnapshot = await FirebaseFirestore.instance.collection('cars').doc(widget.carId).get();
    if (!carSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mobil tidak ditemukan!')),
      );
      return;
    }

    // Menghitung total harga berdasarkan tanggal mulai dan selesai
    int totalHarga = hitungTotalHarga(
      _tanggalMulaiController.text,
      _tanggalSelesaiController.text,
      carSnapshot['harga_perhari'],
    );

    // Membuat objek data untuk disimpan ke Firestore
    Map<String, dynamic> dataSewa = {
      'carId': widget.carId,
      'userId': userId,
      'metode': _metodePembayaran,
      'status': 'menunggu pembayaran', // Status default
      'tanggalmulai': _tanggalMulaiController.text, // Menggunakan string langsung
      'tanggalselesai': _tanggalSelesaiController.text, // Menggunakan string langsung
      'totalharga': totalHarga,
      'alamat': _alamatController.text,
      'kontak': _kontakController.text,
      'nama': _namaController.text,
    };

    // Mengirim data ke Firestore dalam koleksi 'rental'
    try {
      // Menyimpan data sewa ke koleksi 'rental'
      DocumentReference docRef = await FirebaseFirestore.instance.collection('rental').add(dataSewa);

      // Update status mobil menjadi "Pending" di koleksi 'cars'
      await FirebaseFirestore.instance.collection('cars').doc(widget.carId).update({
        'status': 'Pending',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data penyewaan berhasil disimpan')),
      );
      _formKey.currentState!.reset();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $error')),
      );
    }
  }

  int hitungTotalHarga(String tanggalMulai, String tanggalSelesai, int hargaPerHari) {
    DateTime mulai = DateFormat('dd/MM/yyyy').parse(tanggalMulai);
    DateTime selesai = DateFormat('dd/MM/yyyy').parse(tanggalSelesai);
    int durasi = selesai.difference(mulai).inDays + 1;
    return durasi * hargaPerHari;
  }
}

void main() {
  runApp(MaterialApp(
    home: FormSewa(carId: 'car1', userId: 'user1'),
  ));
}
