import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ourcabsdriver/Models/drivers.dart';
import 'package:ourcabsdriver/Models/rideDetails.dart';
import 'package:ourcabsdriver/config.dart';
import 'package:ourcabsdriver/main.dart';
import 'package:ourcabsdriver/notification/notificationDialog.dart';
import 'package:ourcabsdriver/notification/pushnotification.dart';

class Homescreen extends StatefulWidget {
  @override
  _HomescreenState createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapcontroller;

  PushNotification pushNotification = PushNotification();

  String address;

  var geolocator = Geolocator();
  String driverStatusText = "Offline Now - Go Online ";

  Color driverStatusColor = Colors.black;
  Set<Marker> _marker = {};
  LatLng latLng;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(12.972442, 77.580643),
    zoom: 14.4746,
  );

  bool get wantKeepAlive => true;

  getCurrentdriverInfo() async {
    user = FirebaseAuth.instance.currentUser;
    status == "accepted";
    btnTitle = "Arrived";
    if (isDriverAvailable == true) {
      setState(() {
        driverStatusColor = Colors.green;
        driverStatusText = "Online Now ";
      });
    }

    driversRef.child(user.uid).once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        drivers = Drivers.fromSnapshot(dataSnapshot);
      }
    });

    pushNotification.initialize(context);
    print("Printing Token");
    pushNotification.gettoken();
  }

  @override
  void initState() {
    getCurrentdriverInfo();

    super.initState();
  }

  void locatePostion() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currpost = position;

    latLng = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: latLng, zoom: 14);

    newGoogleMapcontroller
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    setState(() async {
      _marker.add(Marker(
          markerId: MarkerId("Current Location"),
          position: latLng,
          icon: await icon));
    });

    //address = await AssistantMethods.searchCoordinateAddress(position, context);
  }

  // showRequestbox(RideDetails rideDetails) {
  //   return showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) => NotificationDialog(
  //             rideDetails: rideDetails,
  //           ));
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapcontroller = controller;
              locatePostion();
            },
            markers: _marker,
          ),

          Positioned(
            right: 10,
            bottom: 20,
            child: GestureDetector(
              onTap: () async {
                locatePostion();
                print(currpost);
              },
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                      color: Colors.grey[700],
                      blurRadius: 10,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7))
                ], color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.my_location),
              ),
            ),
          ),
          //online offline driver Container
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: double.infinity,
            color: Colors.black87,
          ),
          Positioned(
            top: 10.0,
            left: 0.0,
            right: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: RaisedButton(
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(24.0),
                    ),
                    onPressed: () {
                      if (isDriverAvailable == false) {
                        makeDriverOnlineNow();
                        getLocationLiveUpdates();
                        print(isDriverAvailable);
                        //sleep(Duration(seconds: 10));

                        setState(() {
                          driverStatusColor = Colors.green;
                          driverStatusText = "Online Now ";
                          isDriverAvailable = true;
                        });

                        //displayToastMessage("you are Online Now.", context);
                      } else {
                        makeDriverOfflineNow();
                        print(isDriverAvailable);
                        //sleep(Duration(seconds: 10));

                        setState(() {
                          driverStatusColor = Colors.black;
                          driverStatusText = "Offline Now - Go Online ";
                          isDriverAvailable = false;
                        });

                        //displayToastMessage("you are Offline Now.", context);
                      }
                    },
                    color: driverStatusColor,
                    child: Padding(
                      padding: EdgeInsets.all(17.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            driverStatusText,
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.019,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Icon(
                            Icons.phone_android,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.height * 0.027,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }

  void makeDriverOnlineNow() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currpost = position;

    Geofire.initialize("availableDrivers");
    Geofire.setLocation(user.uid, currpost.latitude, currpost.longitude);

    FirebaseFirestore.instance
        .collection("Driver")
        .doc(user.phoneNumber)
        .get()
        .then((value) {
      String name = value.data()['Name'];
      String cname = value.data()['Car']['CName'];
      String cmodel = value.data()['Car']['Cmodel'];
      String ccolor = value.data()['Car']['CColor'];
      String rno = value.data()['Car']['Rno'];
      String type = value.data()['Car']['type'];
      String phno = value.data()['Phone'];
      String ppic = value.data()['URLs']["Profile"];
      Map<String, dynamic> data = {
        "Name": name,
        "Phone": phno,
        "CName": cname,
        "CModel": cmodel,
        "CColor": ccolor,
        "Rno": rno,
        "type": type,
        "ppic": ppic,
        "newRide": "searching"
      };
      PushNotification pushNotification = new PushNotification();
      pushNotification.gettoken();
      FirebaseDatabase.instance
          .reference()
          .child("Drivers")
          .child(user.uid)
          .update(data);
    });

    // FirebaseDatabase.instance
    //     .reference()
    //     .child("Drivers")
    //     .child(user.uid)
    //     .child("newRide")
    //     .onValue
    //     .listen((event) {});
  }

  void getLocationLiveUpdates() {
    homeTabPageStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currpost = position;
      if (isDriverAvailable == true) {
        Geofire.setLocation(user.uid, position.latitude, position.longitude);
      }
      LatLng latLng = LatLng(position.latitude, position.longitude);
      newGoogleMapcontroller.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  void makeDriverOfflineNow() {
    Geofire.removeLocation(user.uid);
    FirebaseDatabase.instance
        .reference()
        .child("Drivers")
        .child(user.uid)
        .onDisconnect();
    FirebaseDatabase.instance
        .reference()
        .child("Drivers")
        .child(user.uid)
        .remove();
    rideRequestRef = null;
  }
}
