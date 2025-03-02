import 'package:agrivision/screens/home_screen.dart';
import 'package:agrivision/utiles/routes/routes.dart';
import 'package:agrivision/utiles/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AgriVision',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: RoutesName.homeScreen,
        onGenerateRoute: Routes.generateRoute,
      ),
    );
  }
}
