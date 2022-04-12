import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ourcabsdriver/Models/drivers.dart';
import 'package:ourcabsdriver/Models/rideDetails.dart';
import 'package:ourcabsdriver/config.dart';
import 'package:ourcabsdriver/main.dart';
import 'package:ourcabsdriver/notification/newRideScreen.dart';
import 'package:ourcabsdriver/notification/progress.dart';
import 'package:ourcabsdriver/notification/pushnotification.dart';

class Earning extends StatefulWidget {
  @override
  _EarningState createState() => _EarningState();
}

class _EarningState extends State<Earning> {
  RideDetails rideDetails = RideDetails();
  bool values;
  getCurrentdriverInfo() async {
    // user = FirebaseAuth.instance.currentUser;

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
    checkdata();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          // appBar: AppBar(
          //   title: Text('Trip History'),
          //   backgroundColor: Colors.black87,
          //   leading: Icon(Icons.),

          // ),
          body: Column(
        children: [
          Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.07,
              padding: const EdgeInsets.all(8.0),
              color: Colors.black,
              child: Center(
                child: Text(
                  'Earnings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )),
          streambuilder()
        ],
      )),
    );
  }

  streambuilder() {
    print("valuesv" + values.toString());
    if (values == true) {
      return Expanded(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Ride Request")
              .where("driver_phone", isNull: false)
              .where("driver_phone", isEqualTo: drivers.phone)

              // .orderBy('Date', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        size: 150,
                      ),
                      Text(
                        "You have not taken any ride yet. \n         Go Online to take rides",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      )
                    ]),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                return cart(index, snapshot.data.docs[index]);
              },
            );
          },
        ),
      );
    } else {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_rounded,
                size: 150,
              ),
              Text(
                "You have not taken any ride yet. \n         Go Online to take rides",
                style: TextStyle(
                  fontSize: 20,
                ),
              )
            ]),
      );
    }
  }

  checkdata() {
    FirebaseFirestore.instance
        .collection("Ride Request")
        .where("driver_phone", isNull: false)
        .where("driver_phone", isEqualTo: drivers.phone)
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        print("values " + value.docs.toString());
        //noData();
        setState(() {
          values = false;
        });
      } else {
        setState(() {
          values = true;
        });
      }
    });
  }

  // noData() {
  //   print("Function called1");
  //   return Center(
  //     child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
  //       Icon(
  //         Icons.warning_rounded,
  //         size: 150,
  //       ),
  //       Text("Currently there is no rides available")
  //     ]),
  //   );
  // }

  cart(int index, QueryDocumentSnapshot docs) {
    String fares;
    print("Retrive function called");

    String stats = docs['status'];
    String reqid;
    print("Status" + stats);

    if (stats == 'ended') {
      fares = docs['fares'].toString();
    } else if (stats == "cancelled") {
      fares = "CD";
    } else {
      fares = "OG";
      reqid = docs.id.toString();
    }

    return GestureDetector(
      onTap: () {
        if (fares == "OG") {
          print("Doc Id" + docs.id.toString());
          String docid = docs.id.toString();
          // showDialog(
          //     context: context,
          //     builder: (BuildContext context) => CircularProgressIndicator());
          newRequestRef.child(docid).once().then((dataSnapshot) {
            if (dataSnapshot.value == null) {
              showDialog(
                context: context,
                builder: (context) => new AlertDialog(
                  //title: new Text('Your ride has been cancelled'),
                  content: new Text(
                      'Ride is not available or ride has been cancelled. Please book a new cab'),
                  actions: <Widget>[
                    new GestureDetector(
                      onTap: () {
                        Navigator.pop(context);

                        FirebaseFirestore.instance
                            .collection("Ride Request")
                            .doc(docid)
                            .update({"status": "cancelled"});
                      },
                      child: Text("OK"),
                    ),
                  ],
                ),
              );
            }

            if (dataSnapshot.value != null) {
              print("value" +
                  dataSnapshot.value['pickup']['latitude'].toString());
              setState(() {
                status = dataSnapshot.value['status'];
              });
              double pickUpLocationLat = double.parse(
                  dataSnapshot.value['pickup']['latitude'].toString());
              double pickUpLocationLng = double.parse(
                  dataSnapshot.value['pickup']['longitude'].toString());
              String pickUpAddress =
                  dataSnapshot.value['pickup_address'].toString();

              double dropOffLocationLat = double.parse(
                  dataSnapshot.value['dropoff']['latitude'].toString());
              double dropOffLocationLng = double.parse(
                  dataSnapshot.value['dropoff']['longitude'].toString());
              String dropOffAddress =
                  dataSnapshot.value['dropoff_address'].toString();

              String paymentMethod =
                  dataSnapshot.value['payment_method'].toString();
              String rider_phone = dataSnapshot.value["rider_phone"];
              String ride_date = dataSnapshot.value["created_at"];
              String requestorId = dataSnapshot.value["requestId"];
              String riderName = dataSnapshot.value["Name"];
              String otp = dataSnapshot.value["otp"].toString();

              rideDetails.ride_request_id = docs.id;
              rideDetails.rider_name = riderName;
              rideDetails.pickup_address = pickUpAddress;
              rideDetails.dropoff_address = dropOffAddress;
              rideDetails.pickup = LatLng(pickUpLocationLat, pickUpLocationLng);
              rideDetails.dropoff =
                  LatLng(dropOffLocationLat, dropOffLocationLng);
              rideDetails.payment_method = paymentMethod;
              rideDetails.rider_phone = rider_phone;
              rideDetails.date = ride_date;
              rideDetails.requestId = requestorId;
              rideDetails.otp = otp;
              rideDetails.status = dataSnapshot.value['status'];
              print("RideDetails" + rideDetails.otp.toString());

              if (status == "accepted") {
                setState(() {
                  btnTitle = "Arrived";
                  status = "accepted";
                });
              } else if (status == "arrived") {
                setState(() {
                  btnTitle = "Start Trip";
                  btnColor = Colors.purple;
                });
              } else if (status == "onride") {
                setState(() {
                  btnTitle = "End Trip";
                  btnColor = Colors.redAccent;
                });
              }
            }
          });
          // Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      NewRideScreen(rideDetails: rideDetails)));
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(8.0),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(docs['created_at'].toString(),
                          style:
                              GoogleFonts.raleway(fontWeight: FontWeight.bold)),
                      // Text(
                      //   docs.id.toString(),
                      //   style: GoogleFonts.raleway(color: Colors.grey),
                      // ),
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                  ),
                  Text((fares != "CD")
                      ? (fares != "OG")
                          ? "₹" + fares
                          : fares
                      : fares),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Icon(
                        Icons.brightness_1,
                        size: 5,
                      ),
                      Text("I"),
                      Icon(Icons.brightness_1, size: 5),
                    ],
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(docs['pickup_address'].toString(),
                            overflow: TextOverflow.ellipsis),
                        SizedBox(height: 5),
                        Text(docs['dropoff_address'].toString(),
                            overflow: TextOverflow.ellipsis)
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
