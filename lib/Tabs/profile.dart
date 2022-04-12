import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ourcabsdriver/Models/driverdetails.dart';
import 'package:ourcabsdriver/Models/drivers.dart';
import 'package:ourcabsdriver/config.dart';
import 'package:ourcabsdriver/login/detail.dart';

import 'package:ourcabsdriver/login/login.dart';
import 'package:ourcabsdriver/main.dart';
import 'package:ourcabsdriver/notification/pushnotification.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  DriverDetails driverDetails = DriverDetails();
  getCurrentdriverInfo() async {
    user = FirebaseAuth.instance.currentUser;

    driversRef.child(user.uid).once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        drivers = Drivers.fromSnapshot(dataSnapshot);
      }
    });

    PushNotification pushNotification = PushNotification();

    pushNotification.initialize(context);
    print("Printing Token");
    pushNotification.gettoken();
  }

  @override
  void initState() {
    getCurrentdriverInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     // Add your onPressed code here!
        //     Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //             builder: (context) => Detail(
        //                   driverDetails: driverDetails,
        //                 )));
        //   },
        //   child: const Icon(Icons.edit_outlined),
        //   backgroundColor: Colors.black,
        // ),
        body: Column(
      children: [
        Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.06,
            padding: const EdgeInsets.all(8.0),
            color: Colors.black,
            child: Stack(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.024,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: GestureDetector(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Login()));
                    },
                    child: Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            )),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("Driver")
                .where("Phone", isEqualTo: user.phoneNumber)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Text("No data ");
              } else {
                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return cart(index, snapshot.data.docs[index]);
                  },
                );
              }
            },
          ),
        ),
      ],
    ));
  }

  cart(int index, QueryDocumentSnapshot docs) {
    double starCounter = double.parse(docs['Rating'].toString());

    driverDetails.name = docs['Name'].toString();
    driverDetails.email = docs['Email'].toString();
    driverDetails.gender = docs['Gender'].toString();
    driverDetails.street = docs['Address']['Street'].toString();
    driverDetails.city = docs['Address']['City'].toString();
    driverDetails.state = docs['Address']['State'].toString();
    driverDetails.pin = docs['Address']['PinCode'].toString();
    driverDetails.cname = docs['Car']['CName'].toString();
    driverDetails.cmodel = docs['Car']['Cmodel'].toString();
    driverDetails.ccolor = docs['Car']['CColor'].toString();
    driverDetails.rno = docs['Car']['Rno'].toString();
    driverDetails.type = docs['Car']['type'].toString();
    driverDetails.ano = docs['Verification']['Aadar No'].toString();
    driverDetails.lno = docs['Verification']['Licence No'].toString();
    driverDetails.pno = docs['Verification']['Pan No'].toString();
    driverDetails.rating = docs['Rating'].toString();

    print("Driver Details " + driverDetails.rno.toString());

    return Container(
      height: MediaQuery.of(context).size.height,
      //padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey[700],
          )
        ],
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            height: MediaQuery.of(context).size.height * 0.2,
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.height * 0.1,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        image: NetworkImage(docs["URLs"]["Profile"])),
                    shape: BoxShape.circle,
                  ),
                  // child: (ppurl != null)
                  //     ? Image.network(ppurl)
                  //     : Icon(Icons.person_add_alt),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      docs['Name'].toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                    SmoothStarRating(
                      rating: starCounter,
                      borderColor: Colors.white,
                      color: Colors.white,
                      allowHalfRating: true,
                      starCount: 5,
                      size: 20,
                      isReadOnly: true,
                    ),
                    Text(
                      docs['Email'].toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      docs['Phone'].toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.001,
                    ),
                    Text(
                      'Car Details:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.001,
                    ),
                    Text(
                        (docs['Car']['CName'].toString() == "Auto")
                            ? docs['Car']['CName'].toString()
                            : docs['Car']['CName'].toString() +
                                " " +
                                docs['Car']['Cmodel'].toString(),
                        style: TextStyle(
                          fontSize: 15,
                        )),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.001,
                    ),
                    Text((docs['Car']['CColor'].toString() != null)?docs['Car']['CColor'].toString():null,
                        style: TextStyle(
                          fontSize: 15,
                        )),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.001,
                    ),
                    Text(docs['Car']['Rno'].toString(),
                        style: TextStyle(
                          fontSize: 15,
                        )),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    Text(
                      'Address:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.001,
                    ),
                    Text(docs['Address']['Street'].toString(),
                        style: TextStyle(
                          fontSize: 15,
                        )),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.001,
                    ),
                    Text(docs['Address']['City'].toString(),
                        style: TextStyle(
                          fontSize: 15,
                        )),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.001,
                    ),
                    Text(docs['Address']['State'].toString(),
                        style: TextStyle(
                          fontSize: 15,
                        )),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.001,
                    ),
                    Text(docs['Address']['PinCode'].toString(),
                        style: TextStyle(
                          fontSize: 15,
                        )),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    Text(
                      'Verification Details:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.001,
                    ),
                    Text(docs['Verification']['Aadar No'].toString(),
                        style: TextStyle(
                          fontSize: 15,
                        )),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.001,
                    ),
                    Text(docs['Verification']['Licence No'].toString(),
                        style: TextStyle(
                          fontSize: 15,
                        )),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.001,
                    ),
                    Text(docs['Verification']['Pan No'].toString(),
                        style: TextStyle(
                          fontSize: 15,
                        )),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
