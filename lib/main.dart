import 'package:flutter/material.dart';
import 'package:sentry/screens/homescreen.dart';
import 'package:sentry/screens/register.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black,brightness: Brightness.light,),
        elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.black),foregroundColor: MaterialStatePropertyAll(Colors.white))),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(color: Colors.black),
        primaryColor: Colors.black,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 255, 255),
          brightness: Brightness.dark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.white),foregroundColor: MaterialStatePropertyAll(Colors.black))),
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.white,
        useMaterial3: true,
      ),
      home: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(),builder: ((context, snapshot) {
        if(snapshot.hasData){
          return const HomePage();
        }
        else{
          return const RegisterScreen();
        }
      })),
    );
  }
}


