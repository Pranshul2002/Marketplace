import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketplace/HomePage.dart';

class AddItem extends StatefulWidget {
  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  TextEditingController price = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController contact = TextEditingController();
  int count = 0;
  File _image;
  final ImagePicker picker = ImagePicker();
  String doc_name = "";
  List<dynamic> Urls = [];
  final _formKey = GlobalKey<FormState>();
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  List<String> upload;
  @override
  void initState() {
    super.initState();
    upload = HomePageState.pref.getStringList("upload") != null
        ? HomePageState.pref.getStringList("upload")
        : [];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                height: 100,
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: (val) {
                    if (val.length != 10) {
                      return "Enter correct phone number";
                    } else
                      return null;
                  },
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  controller: contact,
                  decoration: InputDecoration(
                      hintText: "Enter Phone Number",
                      fillColor: Color(0xfff5f0e1),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(20)))),
                ),
              ),
              Container(
                height: 100,
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: (val) {
                    if (int.parse(val) <= 0) {
                      return "Enter correct price";
                    } else
                      return null;
                  },
                  keyboardType: TextInputType.number,
                  controller: price,
                  decoration: InputDecoration(
                      hintText: "Enter Price",
                      fillColor: Color(0xfff5f0e1),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(20)))),
                ),
              ),
              Container(
                height: 100,
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: (val) {
                    if (val.length <= 0) {
                      return "Enter correct location";
                    } else
                      return null;
                  },
                  controller: location,
                  decoration: InputDecoration(
                      hintText: "Enter Location",
                      fillColor: Color(0xfff5f0e1),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(20)))),
                ),
              ),
              Container(
                height: 100,
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: (val) {
                    if (val.length <= 0) {
                      return "Enter correct description";
                    } else
                      return null;
                  },
                  controller: description,
                  decoration: InputDecoration(
                      hintText: "Enter Description of the product",
                      fillColor: Color(0xfff5f0e1),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(20)))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () async {
                      await getImage();
                      String name =
                          DateTime.now().toString() + contact.text.toString();

                      if (_image != null) {
                        await firebase_storage.FirebaseStorage.instance
                            .ref('$name/${count.toString()}.png')
                            .putFile(_image);

                        firebase_storage.FirebaseStorage.instance
                            .ref('$name/${count.toString()}.png')
                            .getDownloadURL()
                            .then((value) {
                          setState(() {
                            count++;
                            Urls.add(value);
                            Fluttertoast.showToast(
                                msg: "Image Uploaded",
                                toastLength: Toast.LENGTH_SHORT);
                            if (doc_name == "") {
                              doc_name = name;
                            }
                          });
                        });
                      }
                    },
                    child: Text("Upload images")),
              ),
              Expanded(child: Container()),
              ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate() && doc_name != "") {
                      await FirebaseFirestore.instance
                          .collection("market")
                          .doc(doc_name)
                          .set({
                        "description": description.text,
                        "price": int.parse(price.text),
                        "location": location.text,
                        "images": Urls,
                        "phone_number": int.parse(contact.text)
                      });
                      upload.add(doc_name);
                      await HomePageState.pref.setStringList("upload", upload);
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: Text("Post"))
            ],
          ),
        ),
      ),
    );
  }
}
