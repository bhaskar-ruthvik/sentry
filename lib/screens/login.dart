import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sentry/screens/homescreen.dart';

final _firebase = FirebaseAuth.instance;

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  String _email = "";
  String _password = ""; 

  void _submitForm() async {
    final isValid = formKey.currentState!.validate();
    if(!isValid){
      return;
    }
    formKey.currentState!.save();

    try {
      await _firebase.signInWithEmailAndPassword(email: _email, password: _password);
      if(FirebaseAuth.instance.currentUser!=null){
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx){
          return const HomePage();
        }));
      }
    } on FirebaseAuthException catch(error){
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message ?? 'Authentication failed.')));
      }
    
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(padding: EdgeInsets.symmetric(horizontal: 42.0),
        child:  Center(
          
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Text("Sentry",
                    style: GoogleFonts.montserrat(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold,fontSize: 42),),
                  ),
                //    Container(
                //   margin: const EdgeInsets.only(
                //       top: 30, bottom: 20, left: 20, right: 20),
                //   width: 200,
                //   child: Image.network( 'https://images.unsplash.com/photo-1690342824253-4d9488961ded?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=3540&q=80'),
                // ),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      label: Text('Email: ')
                    ),
                    validator: (value) {
                       if(value == null || value.trim().isEmpty || !value.contains('@')){
                            return 'Please enter a valid email address';
                          }
                          return null;
                    },
                    onSaved: (newValue) {
                      _email = newValue!;
                    },
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      label: Text('Password: ')
                    ),
                    validator: (value) {
                          if(value==null || value.isEmpty || value.trim().length<4){
                            return 'Please enter atleast 4 characters';
                          }
                          return null;
                        },
                    onSaved: (newValue) {
                      _password = newValue!;
                    },
                  ),
                 SizedBox(
                    height: 24,
                  ),
                  TextButton(onPressed: (){
                     Navigator.of(context).pop();
                   }, child: Text('Don\'t have an account? Register here',style: TextStyle(color: Theme.of(context).primaryColor),)),
                  Padding(padding: EdgeInsets.fromLTRB(0,24.0,0,8),
                  child: SizedBox(
                    height: 50,
                    width: 250,
                    child: ElevatedButton(onPressed: _submitForm, child: Center(
                      child:  Text('Login',style: GoogleFonts.montserrat(fontSize: 16,fontWeight: FontWeight.bold),),
                    )   
                    
                    )),
                  ),
                  
                    //  const Text('------------------- OR -------------------'),
               
                  Padding(padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 50,
                    width: 250,
                    child: ElevatedButton(onPressed: (){}, child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.google,size: 16.0,),
                        SizedBox(width: 8.0,),
                        Text('Sign in using Google',style: GoogleFonts.montserrat(fontSize: 16,fontWeight: FontWeight.bold),),
                      ],
                    )),
                  )
                  ,
                  ),
                  // Padding(padding: EdgeInsets.all(8.0),
                  // child:  SizedBox(
                  //   height: 50,
                  //   width: 250,
                  //   child: ElevatedButton(onPressed: (){}, child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Icon(FontAwesomeIcons.apple,size: 20.0,),
                  //       SizedBox(width: 8.0,),
                  //       Text('Sign in using Apple',style: GoogleFonts.montserrat(fontSize: 16,fontWeight: FontWeight.bold),),
                  //     ],
                  //   )),
                  // ),),
                
                 
                ],
              ),
            )
            ,
          )
          ,)
       
        ),
      )
      ,
    );
  }
}