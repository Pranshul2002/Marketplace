import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marketplace/AddItem.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  static SharedPreferences pref;
  bool loading = true;
  List<String> uploaded = [];
  List<String> fav = [];
  bool favourite = false;
  bool run = true;
  getShared() async {
    SharedPreferences.setMockInitialValues({});
    pref = await SharedPreferences.getInstance();
    uploaded = pref.getStringList("upload") != null
        ? pref.getStringList("upload")
        : [];
    fav = pref.getStringList("favourite") != null
        ? pref.getStringList("favourite")
        : [];
    setState(() {
      loading = false;
    });
  }

  Widget itemBox(DocumentSnapshot ds) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 25.0, right: 25.0, top: 16, bottom: 16),
      child: Container(
        width: MediaQuery.of(context).size.width - 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.blueAccent),
        child: Column(
          children: [
            Container(
              height: 200,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: ds.data()["images"].length,
                  itemBuilder: (context, index) => CachedNetworkImage(
                        imageUrl: ds.data()["images"][index],
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      )),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Price: \u{20B9}${ds.data()["price"].toString()}",
                    style: TextStyle(color: Color(0xfff5f0e1), fontSize: 17),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Location: ${ds.data()["location"]}",
                    style: TextStyle(color: Color(0xfff5f0e1), fontSize: 17),
                  ),
                ),
              ],
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text(
                ds.data()["description"],
                style: TextStyle(color: Color(0xfff5f0e1), fontSize: 17),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      String url =
                          "tel://" + ds.data()["phone_number"].toString();
                      await canLaunch(url)
                          ? await launch(url)
                          : print("Cannot launch");
                    },
                    child: Text(
                      "Contact",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green)),
                  ),
                ),
                if (uploaded.contains(ds.id))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        uploaded.remove(ds.id);
                        await pref.setStringList("upload", uploaded);
                        FirebaseFirestore.instance
                            .collection("market")
                            .doc(ds.id)
                            .delete();
                        await firebase_storage.FirebaseStorage.instance
                            .ref(ds.id)
                            .delete();
                      },
                      child: Text(
                        "Delete",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.green)),
                    ),
                  ),
                IconButton(
                    icon: Icon(
                      fav.contains(ds.id)
                          ? Icons.star
                          : Icons.star_border_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (!fav.contains(ds.id)) {
                        setState(() {
                          fav.add(ds.id);
                          pref.setStringList("favourite", fav);
                          print(fav);
                        });
                      } else {
                        setState(() {
                          fav.remove(ds.id);
                          pref.setStringList("favourite", fav);
                          print(fav);
                        });
                      }
                    }),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getShared();
  }

  @override
  Widget build(BuildContext context) {
    if (run) {
      setState(() {
        getShared();
        print(uploaded);
        run = false;
      });
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        child: Icon(Icons.add),
        onPressed: () async {
          run = await Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => AddItem()));
          setState(() {});
        },
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text("MarketPlace"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                icon: Icon(favourite ? Icons.star : Icons.star_border_outlined),
                onPressed: () {
                  setState(() {
                    favourite = !favourite;
                  });
                }),
          ),
        ],
      ),
      body: loading
          ? Center(
              child: Text("loading"),
            )
          : Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: 30,
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("market")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container(
                            padding: EdgeInsets.all(20),
                            alignment: Alignment.center,
                            child: Text(
                              'No Data...',
                            ),
                          );
                        } else {
                          return ListView.builder(
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (favourite == false)
                                return itemBox(snapshot.data.docs[index]);
                              else {
                                if (fav
                                    .contains(snapshot.data.docs[index].id)) {
                                  return itemBox(snapshot.data.docs[index]);
                                } else {
                                  return SizedBox.shrink();
                                }
                              }
                            },
                          );
                        }
                      }),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
    );
  }
}
