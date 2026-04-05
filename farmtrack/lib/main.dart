import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/auth_wrapper.dart';
import 'services/cart_service.dart';
import 'services/order_service.dart';
import 'services/address_service.dart';
import 'services/payment_service.dart';
import 'providers/theme_provider.dart';
import 'providers/category_provider.dart';
import 'providers/navigation_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartService()),
        ChangeNotifierProvider(create: (context) => OrderService()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AddressService()),
        ChangeNotifierProvider(create: (context) => PaymentService()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'FarmTrack UI',
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              scaffoldBackgroundColor: Colors.white,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF678D46),
                primary: const Color(0xFF678D46),
              ),
              textTheme: GoogleFonts.poppinsTextTheme(),
              useMaterial3: true,
            ),
            darkTheme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF121212),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF678D46),
                brightness: Brightness.dark,
                primary: const Color(0xFF678D46),
              ),
              textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
              cardColor: const Color(0xFF1E1E1E),
              useMaterial3: true,
            ),
            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
