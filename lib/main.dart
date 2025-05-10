import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:agrivision/providers/auth_provider.dart';
import 'package:agrivision/providers/navigation_provider.dart';
import 'package:agrivision/utiles/routes/routes.dart';
import 'package:agrivision/utiles/routes/routes_name.dart';
import 'firebase_options.dart';
import 'landing_wrapper.dart'; // Import LandingWrapper

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Use correct Firebase config
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AgriVision',
        theme: ThemeData(
          primaryColor: Color(0xFF2E7D32),
          scaffoldBackgroundColor: Color(0xFFF1F8E9),
        ),

        //  Instead of using static route, we dynamically load screen based on login
        home: LandingWrapper(),

        //  Use your defined routes
        onGenerateRoute: Routes.generateRoute,
        initialRoute: RoutesName.navigationMenu, // Optional, for future deep linking
      ),
    );
  }
}


