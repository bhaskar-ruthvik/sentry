import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

final _firebase = FirebaseAuth.instance;
final picker = ImagePicker();
const uuid = Uuid();
class AddImageScreen extends StatefulWidget{
  const AddImageScreen({super.key});

  @override
  State<AddImageScreen> createState() => _AddImageScreenState();
}

class _AddImageScreenState extends State<AddImageScreen> {
  final formKey = GlobalKey<FormState>();
   File? image;
  String name = "";
  bool _isUploading = false;
   void pickImage() async {
     final pickedImage =  await picker.pickImage(source: ImageSource.gallery,maxWidth: 200);
     if(pickedImage!=null){
      setState(() {
        image = File(pickedImage.path);
      });
     }
  }
  void addPerson() async {
    final isValid = formKey.currentState!.validate();
    if(!isValid){
      return;
    }

    formKey.currentState!.save();
    setState(() {
      _isUploading = true;
    });
    final user = _firebase.currentUser!;
    final storageRef = FirebaseStorage.instance.ref().child('users').child('people').child('${user.uid}').child('${uuid.v4()}.jpg');
    await storageRef.putFile(image!);
     final downloadUrl = await storageRef.getDownloadURL();
       FirebaseFirestore.instance.collection('users/people/${user.uid}').doc(uuid.v4()).set({
        'name': name,
        'url': downloadUrl
      });
      if(mounted){
        setState(() {
          _isUploading = false;
        });
      }
       
      Navigator.of(context).pop();
      setState(() {
        
      });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: SafeArea(
          child: Column(
            children: [
                  Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(onPressed: (){
                    Navigator.of(context).pop();
                  }, icon: const Icon(Icons.close_rounded)),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 42.0,vertical: 16.0),
                  child: Column(
                  children: [
                    InkWell(
                              onTap: pickImage,
                               child: Container(
                                             decoration: const BoxDecoration(
                                shape: BoxShape.circle
                                             ),
                                             clipBehavior: Clip.hardEdge,
                                             margin: const EdgeInsets.only(
                                  top: 25, bottom: 5, left: 20, right: 20),
                                             width: 200,
                                             child: image==null? Image.asset('assets/images/avatar.jpeg',fit: BoxFit.cover,height: 150,) : Image.file(image!,fit: BoxFit.cover,),
                                           ),
                             ),
                              Text('Pick Image',style: GoogleFonts.montserrat(color: Theme.of(context).primaryColor),),
                    TextFormField(
                              decoration: InputDecoration(
                                label: Text('Person Name: ',style: GoogleFonts.montserrat(fontSize: 10))
                              ),
                              validator: (value) {
                                 if(value == null || value.trim().isEmpty){
                                      return 'Please enter a valid name';
                                    }
                                    return null;
                              },
                              onSaved: (newValue) {
                                name = newValue!;
                              },
                            ),
                           !_isUploading?  Padding(padding: EdgeInsets.fromLTRB(0,42.0,0,8),
                        child: SizedBox(
                          height: 50,
                          width: 150,
                          child: ElevatedButton(onPressed: addPerson, child: Center(
                            child:  Text('Add Person',style: GoogleFonts.montserrat(fontSize: 14,fontWeight: FontWeight.bold),),
                          )   
                          
                          )),
                        ) : const CircularProgressIndicator(),
                  ],
                      ),
                ),
              ),
            ],
          )
              ,
        )
      )
      ,
    );
  }
}