import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final picker = ImagePicker();
final _firebase = FirebaseAuth.instance;
class RegisterScreen extends StatefulWidget{
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  File? avatarImage;
  String username = "";
  String password = "";
  var _isLogin = false;
  var _isUploading = false;
  final formKey = GlobalKey<FormState>();
  void pickImage() async {
     final pickedImage =  await picker.pickImage(source: ImageSource.gallery,maxWidth: 200);
     if(pickedImage!=null){
      setState(() {
        avatarImage = File(pickedImage.path);
      });
     }
  }
   void _submitForm() async {
    final isValid = formKey.currentState!.validate();
    if(!isValid || (!_isLogin && avatarImage==null)){
      return;
    }


    formKey.currentState!.save();
    try{
      setState(() {
        _isUploading = true;
      });
    if(_isLogin){
       await _firebase.signInWithEmailAndPassword(email: username, password: password);
    }else{
      final userCredentials =  await _firebase.createUserWithEmailAndPassword(email: username, password: password);

     final storageRef = FirebaseStorage.instance.ref().child('user_images').child('${userCredentials.user!.uid}.jpg');

     final peopleRef = FirebaseStorage.instance.ref().child('users').child('people').child(userCredentials.user!.uid).child('${userCredentials.user!.uid}.jpg');
      
     await storageRef.putFile(avatarImage!);
     await peopleRef.putFile(avatarImage!);
     if(mounted){
       setState(() {
       _isUploading = false;
     });
     }
    
     final downloadUrl = await storageRef.getDownloadURL();
     final peopleUrl = await peopleRef.getDownloadURL();
     FirebaseFirestore.instance.collection('users').doc('${userCredentials.user!.uid}').set({
      'email' : username,
      'image_url' : downloadUrl
     });
      FirebaseFirestore.instance.collection('users/people/${userCredentials.user!.uid}').doc(userCredentials.user!.uid).set({
        'name': 'You',
        'url': peopleUrl
      });
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
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 42.0),
        child:  Center(
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: _isLogin ?  const EdgeInsets.symmetric(vertical: 32.0): const EdgeInsets.fromLTRB(0,0,0,0),
                    child: Text("Sentry",
                    style: GoogleFonts.montserrat(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold,fontSize: 42),),
                  ),
                  
                  if(!_isLogin) InkWell(
                    onTap: pickImage,
                     child: Container(
                                   decoration: const BoxDecoration(
                      shape: BoxShape.circle
                                   ),
                                   clipBehavior: Clip.hardEdge,
                                   margin: const EdgeInsets.only(
                        top: 25, bottom: 5, left: 20, right: 20),
                                   width: 200,
                                   child: avatarImage==null? Image.asset('assets/images/avatar.jpeg',fit: BoxFit.cover,height: 150,) : Image.file(avatarImage!,fit: BoxFit.cover,),
                                 ),
                   )
                ,
                if(!_isLogin&&  avatarImage==null)
                  Text('Pick Image',style: GoogleFonts.montserrat(color: Theme.of(context).primaryColor),),
                  TextFormField(
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
                      username = newValue!;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      label: Text('Password: ')
                    ),
                    obscureText: true,
                     validator: (value) {
                          if(value==null || value.isEmpty || value.trim().length<4){
                            return 'Please enter atleast 4 characters';
                          }
                          return null;
                        },
                    onSaved: (value) {
                      password = value!;
                    },
                  ),
                  SizedBox(height: 24,),
                   TextButton(onPressed: (){
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                   }, child:  Text(_isLogin ? 'Don\'t have an account? Register here':'Already have an account? Login here',style: TextStyle(color: Theme.of(context).primaryColor),),),
                  if(!_isUploading)
                   Padding(padding: EdgeInsets.fromLTRB(0,24.0,0,8),
                  child: SizedBox(
                    height: 50,
                    width: 250,
                    child: ElevatedButton(onPressed: _submitForm, child: Center(
                      child:  Text(_isLogin? 'Login' : 'Register',style: GoogleFonts.montserrat(fontSize: 16,fontWeight: FontWeight.bold),),
                    )   
                    
                    )),
                  ),
                  if(_isUploading) CircularProgressIndicator(),
                 
              //   const Divider(
              //   color: Colors.white,
              //   height: 25,
              //   thickness: 1,
              //   indent: 0,
              //   endIndent: 0,
              // ),
                  // SizedBox(
                  //   height: 4,
                  // ),
                  
                  Padding(padding: EdgeInsets.fromLTRB(0,8.0,0,8.0),
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