import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Sesuaikan dengan file konfigurasi Firebase
import 'package:provider/provider.dart';
import 'package:aplikasi_rental_mobil/auth/auth_provider.dart';
import 'package:aplikasi_rental_mobil/auth/formlogi.dart'; // Sesuaikan path dengan benar
import 'package:aplikasi_rental_mobil/screen/userDashboard.dart'; // Sesuaikan dengan path yang benar
import 'package:aplikasi_rental_mobil/admin/adminDashboard.dart'; // Sesuaikan dengan path yang benar

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Aplikasi Rental Mobil',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/user_dashboard': (context) => DashboardUSer(), // Sesuaikan dengan layar user dashboard
          '/admin_dashboard': (context) => DashboardAdmin(), // Sesuaikan dengan layar admin dashboard
          // Tambahkan rute lain jika perlu
        },
      ),
    );
  }
}
