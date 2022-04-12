import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ourcabsdriver/Models/AssistantMethods.dart';
import 'package:ourcabsdriver/Models/mapKitAssistant.dart';
import 'package:ourcabsdriver/Models/rideDetails.dart';
import 'package:ourcabsdriver/config.dart';
import 'package:ourcabsdriver/main.dart';
import 'package:ourcabsdriver/notification/collectfare.dart';
import 'package:ourcabsdriver/notification/progress.dart';
import 'package:url_launcher/url_launcher.dart';

class NewRideScreen extends StatefulWidget {
  final RideDetails rideDetails;
  NewRideScreen({this.rideDetails});

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(12.972442, 77.580643),
    zoom: 14.4746,
  );

  @override
  _NewRideScreenState createState() => _NewRideScreenState();
}

class _NewRideScreenState extends State<NewRideScreen> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newRideGoogleMapController;
  TextEditingController otpcontroller = TextEditingController();
  int otp;

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  PolylinePoints polylinePoints = PolylinePoints();
  double mapPaddingFromBottom = 0;
  var geoLocator = Geolocator();
  var locationOptions =
      LocationOptions(accuracy: LocationAccuracy.bestForNavigation);

  Position myPostion;
  StreamSubscription<Event> ridestreamSubscription;

  String durationRide = "";
  String distanceRide = "";
  bool isRequestingDirection = false;

  Timer timer;
  int durationCounter = 0;
  int value1 = 0;

  BitmapDescriptor nearByIcon;

  @override
  void initState() {
    acceptRideRequest();

    super.initState();
  }

  Future<Uint8List> createIconMarker() async {
    if (nearByIcon == null) {
      ByteData byteData =
          await DefaultAssetBundle.of(context).load("images/cabicon.png");
      return byteData.buffer.asUint8List();
    }
  }

  @override
  Widget build(BuildContext context) {
    String otp = widget.rideDetails.otp;
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) =>
                CancelDailog(requestId: widget.rideDetails.ride_request_id));
      },
      child: Scaffold(
          body: Stack(children: [
        GoogleMap(
          padding: EdgeInsets.only(bottom: mapPaddingFromBottom),
          mapType: MapType.normal,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          initialCameraPosition: NewRideScreen._kGooglePlex,
          myLocationEnabled: true,
          polylines: polylineSet,
          markers: markersSet,
          //circles: circlesSet,
          onMapCreated: (GoogleMapController controller) async {
            showDialog(
                context: context,
                builder: (BuildContext context) =>
                    Progressbar(message: "Please wait.."));
            _controllerGoogleMap.complete(controller);
            newRideGoogleMapController = controller;
            print("currentPosition" + currpost.toString());

            setState(() {
              mapPaddingFromBottom = 265.0;
            });

            var currentLatLng = LatLng(currpost.latitude, currpost.longitude);
            var pickUpLatLng = widget.rideDetails.pickup;

            print("currentPosition" +
                currentLatLng.latitude.toString() +
                currentLatLng.longitude.toString());
            print("currentPosition" +
                pickUpLatLng.latitude.toString() +
                pickUpLatLng.longitude.toString());

            await getPlaceDirection(currentLatLng, pickUpLatLng);

            getRideLiveLocationUpdates();
            Navigator.pop(context);
          },
        ),
        Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 2.0,
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  // borderRadius: BorderRadius.only(
                  //     topLeft: Radius.circular(16.0),
                  //     topRight: Radius.circular(16.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                height: MediaQuery.of(context).size.height * 0.35,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            child: Icon(Icons.person, color: Colors.white),
                            backgroundColor: Colors.black,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (widget.rideDetails.rider_name.toString() !=
                                        null
                                    ? widget.rideDetails.rider_name.toString()
                                    : "null"),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Text(
                                (distanceRide.toString() != null
                                    ? distanceRide.toString() +
                                        " away | " +
                                        durationRide.toString()
                                    : "null"),
                                style: TextStyle(color: Colors.grey),
                              )
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.brightness_1,
                            size: 10,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02,
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                (widget.rideDetails.pickup_address.toString() !=
                                        null
                                    ? widget.rideDetails.pickup_address
                                        .toString()
                                    : "null"),
                                style: TextStyle(fontSize: 18.0),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.brightness_1,
                            size: 10,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02,
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                (widget.rideDetails.dropoff_address
                                            .toString() !=
                                        null
                                    ? widget.rideDetails.dropoff_address
                                        .toString()
                                        .toString()
                                    : "null"),
                                style: TextStyle(fontSize: 18.0),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: TextButton(
                              onPressed: () {
                                String phone = widget.rideDetails.rider_phone;
                                launch(('tel://${phone}'));
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.call, color: Colors.red),
                                  Text("Call",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: TextButton(
                              onPressed: () {
                                print("reqId" +
                                    widget.rideDetails.ride_request_id);
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) =>
                                        CancelDailog(
                                          requestId: widget
                                              .rideDetails.ride_request_id,
                                        ));
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.close, color: Colors.red),
                                  Text(
                                    "Cancel",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      RaisedButton(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(5.0),
                        ),
                        onPressed: () async {
                          print("status1" + status);
                          if (status == "accepted") {
                            status = "arrived";
                            String rideRequestId =
                                widget.rideDetails.ride_request_id;

                            newRequestRef
                                .child(rideRequestId)
                                .child("status")
                                .set(status);

                            newRequestRef.child(rideRequestId).once().then(
                                (value) => widget.rideDetails.otp =
                                    value.value['otp'].toString());

                            rideRef
                                .doc(rideRequestId)
                                .update({"status": status});

                            setState(() {
                              btnTitle = "Start Trip";
                              btnColor = Colors.purple;
                            });

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) => Progressbar(
                                message: "Please wait...",
                              ),
                            );

                            await getPlaceDirection(widget.rideDetails.pickup,
                                widget.rideDetails.dropoff);

                            Navigator.pop(context);
                          } else if (status == "arrived") {
                            print('Otp' + widget.rideDetails.otp.toString());
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => AlertDialog(
                                      title:
                                          Center(child: Text("Enter the OTP")),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            height: 30,
                                            width: 100,
                                            child: TextField(
                                                controller: otpcontroller,
                                                keyboardType:
                                                    TextInputType.number,
                                                textAlign: TextAlign.center),
                                          ),
                                          SizedBox(
                                            child: RaisedButton(
                                                color: Colors.black,
                                                onPressed: () {
                                                  print("Ride OTP" +
                                                      OTP.toString());

                                                  if (otpcontroller.text ==
                                                          widget.rideDetails
                                                              .otp ||
                                                      otpcontroller.text ==
                                                          OTP) {
                                                    setState(() {
                                                      status = "onride";
                                                      btnTitle = "End Trip";
                                                      btnColor =
                                                          Colors.redAccent;
                                                    });
                                                    Navigator.pop(context);
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "OTP entered is wrong, Please re-enter the OTP");
                                                  }
                                                },
                                                child: Text("Verify",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ))),
                                          )
                                        ],
                                      ),
                                    ));

                            String rideRequestId =
                                widget.rideDetails.ride_request_id;
                            newRequestRef
                                .child(rideRequestId)
                                .child("status")
                                .set(status);
                            rideRef
                                .doc(rideRequestId)
                                .update({"status": status});

                            initTimer();
                          } else if (status == "onride") {
                            endTheTrip();
                          }
                        },
                        color: Colors.black,
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                btnTitle,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )))
      ])),
    );
  }

  Future<void> getPlaceDirection(
      LatLng pickUpLatLng, LatLng dropOffLatLng) async {
    // showDialog(
    //     context: context,
    //     builder: (BuildContext context) => ProgressDialog(message: "Please wait...",)
    // );

    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);

    //Navigator.pop(context);

    print("This is Encoded Points ::");
    print(details.encodedPoints);

    //Polyline
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints);

    pLineCoordinates.clear();

    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.grey[900],
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }

    newRideGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
      icon: icon,
      // infoWindow:
      //     InfoWindow(title: initialPos.placeName, snippet: "my Location"),
      position: pickUpLatLng,
      markerId: MarkerId("pickUpId"),
    );

    Marker dropOffLocMarker = Marker(
      icon: icon,
      // infoWindow:
      //     InfoWindow(title: finalPos.placeName, snippet: "DropOff Location"),
      position: dropOffLatLng,
      markerId: MarkerId("dropOffId"),
    );

    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(dropOffLocMarker);
    });

    Circle pickUpLocCircle = Circle(
      fillColor: Colors.blueAccent,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.blueAccent,
      circleId: CircleId("pickUpId"),
    );

    Circle dropOffLocCircle = Circle(
      fillColor: Colors.deepPurple,
      center: dropOffLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.deepPurple,
      circleId: CircleId("dropOffId"),
    );

    setState(() {
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
    });
  }

  void getRideLiveLocationUpdates() async {
    LatLng oldPos = LatLng(0, 0);

    Uint8List imagedata = await createIconMarker();

    rideStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currpost = position;
      myPostion = position;
      LatLng mPostion = LatLng(position.latitude, position.longitude);

      var rot = MapKitAssistant.getMarkerRotation(oldPos.latitude,
          oldPos.longitude, myPostion.latitude, myPostion.latitude);

      Marker marker = Marker(
        markerId: MarkerId('animating'),
        position: mPostion,
        icon: BitmapDescriptor.fromBytes(imagedata),
        rotation: rot,
        infoWindow: InfoWindow(title: "Current Location"),
      );

      // Marker animatingMarker = Marker(
      //   markerId: MarkerId("animating"),
      //   position: mPostion,
      //   icon: nearByIcon,
      //   // rotation: rot,
      //   // infoWindow: InfoWindow(title: "Current Location"),
      // );

      if (mounted) {
        setState(() {
          CameraPosition cameraPosition =
              new CameraPosition(target: mPostion, zoom: 17);
          newRideGoogleMapController
              .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

          markersSet
              .removeWhere((marker) => marker.markerId.value == "animating");
          markersSet.add(marker);
        });
      }
      oldPos = mPostion;
      updateRideDetails();

      String rideRequestId = widget.rideDetails.ride_request_id;
      Map locMap = {
        "latitude": currpost.latitude.toString(),
        "longitude": currpost.longitude.toString(),
      };
      newRequestRef.child(rideRequestId).child("driver_location").set(locMap);
    });
  }

  void acceptRideRequest() {
    String rideRequestId = widget.rideDetails.ride_request_id;
    newRequestRef.child(rideRequestId).child("status").set(status);
    newRequestRef.child(rideRequestId).child("driver_name").set(drivers.name);
    newRequestRef.child(rideRequestId).child("driver_phone").set(drivers.phone);
    newRequestRef.child(rideRequestId).child("driver_id").set(drivers.id);
    newRequestRef.child(rideRequestId).child("Regno").set(drivers.car_number);
    newRequestRef.child(rideRequestId).child("ppic").set(drivers.ppic);
    newRequestRef
        .child(rideRequestId)
        .child("car_details")
        .set('${drivers.car_name}');

    Map locMap = {
      "latitude": currpost.latitude.toString(),
      "longitude": currpost.longitude.toString(),
    };
    newRequestRef.child(rideRequestId).child("driver_location").set(locMap);

    Map<String, dynamic> data = {
      "driver_name": drivers.name,
      "driver_phone": drivers.phone,
      "driver_id": drivers.id,
      "Regno": drivers.car_number,
      "ppic": drivers.ppic,
      "car_details": '${drivers.car_name}',
      "status": status
    };
    rideRef.doc(rideRequestId).set(data);

    Random random = Random();
    otp = random.nextInt(9999);
    if (otp.toString().length == 4) {
      OTP = otp.toString();
      newRequestRef.child(rideRequestId).child("otp").set(otp);
    } else {
      otp = random.nextInt(9999);
      OTP = otp.toString();
      newRequestRef.child(rideRequestId).child("otp").set(otp);
    }

    newRequestRef.child(rideRequestId).onValue.listen((event) {
      print("Id Status" + event.snapshot.value["status"]);
      if (event.snapshot.value["status"] == "cancelled") {
        showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Your ride has been cancelled'),
            content: new Text(
                'User has cancelled you ride please click okay to go back'),
            actions: <Widget>[
              new GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);

                  newRequestRef.child(rideRequestId).remove();

                  AssistantMethods.enableHomeTabLiveLocationUpdates();
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
        //rideStreamSubscription.cancel();
      }
    });
  }

  void updateRideDetails() async {
    if (isRequestingDirection == false) {
      isRequestingDirection = true;

      if (myPostion == null) {
        return;
      }

      var posLatLng = LatLng(myPostion.latitude, myPostion.longitude);
      LatLng destinationLatLng;

      if (status == "accepted") {
        destinationLatLng = widget.rideDetails.pickup;
      } else {
        destinationLatLng = widget.rideDetails.dropoff;
      }

      var directionDetails = await AssistantMethods.obtainPlaceDirectionDetails(
          posLatLng, destinationLatLng);
      if (directionDetails != null) {
        setState(() {
          durationRide = directionDetails.durationText;
          distanceRide = directionDetails.distanceText;
        });
      }

      isRequestingDirection = false;
    }
  }

  void initTimer() {
    const interval = Duration(seconds: 1);
    timer = Timer.periodic(interval, (timer) {
      durationCounter = durationCounter + 1;
    });
  }

  endTheTrip() async {
    timer.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Progressbar(
        message: "Please wait...",
      ),
    );

    var currentLatLng = LatLng(myPostion.latitude, myPostion.longitude);

    print("Current location " + currentLatLng.toString());
    print("Drop off location " + widget.rideDetails.pickup.toString());

    var directionalDetails = await AssistantMethods.obtainPlaceDirectionDetails(
        widget.rideDetails.pickup, currentLatLng);

    int fareAmount =
        AssistantMethods.calculateFares(directionalDetails, drivers.carType);

    String rideRequestId = widget.rideDetails.ride_request_id;
    newRequestRef
        .child(rideRequestId)
        .child("fares")
        .set(fareAmount.toString());
    newRequestRef.child(rideRequestId).child("status").set("ended");

    rideRef.doc(rideRequestId).update({"status": "ended"});
    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CollectFareDialog(
          paymentMethod: widget.rideDetails.payment_method,
          fareAmount: fareAmount,
          rideDetails: widget.rideDetails),
    );

    saveEarnings(fareAmount);
  }

  void saveEarnings(int fareAmount) {
    String date, pickup, dropoff;
    String requestId = widget.rideDetails.ride_request_id;

    newRequestRef.child(requestId).remove();
  }
}

class CancelDailog extends StatefulWidget {
  String requestId;
  CancelDailog({this.requestId});
  @override
  _CancelDailogState createState() => _CancelDailogState();
}

class _CancelDailogState extends State<CancelDailog> {
  int groupValue = 1;
  String reason;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        Navigator.pop(context);
      },
      child: Dialog(
          child: Container(
              padding: EdgeInsets.all(10),
              height: MediaQuery.of(context).size.height * 0.52,
              width: MediaQuery.of(context).size.width * 0.99,
              child: Column(children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Text('Reason for cancellation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    )),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Divider(
                  color: Colors.black,
                ),
                RadioListTile(
                    activeColor: Colors.black,
                    title: Text("Rider didn't show up"),
                    value: 1,
                    groupValue: groupValue,
                    onChanged: (int value) {
                      setState(() {
                        reason = "Rider didn't show up";
                        groupValue = value;
                      });
                    }),
                RadioListTile(
                    activeColor: Colors.black,
                    title: Text('Too many riders'),
                    value: 2,
                    groupValue: groupValue,
                    onChanged: (int value) {
                      setState(() {
                        reason = "Too many riders";
                        groupValue = value;
                      });
                    }),
                RadioListTile(
                    activeColor: Colors.black,
                    title: Text('Unable to contact rider'),
                    value: 3,
                    groupValue: groupValue,
                    onChanged: (int value) {
                      setState(() {
                        reason = "Unable to contact rider";
                        groupValue = value;
                      });
                    }),
                RadioListTile(
                    activeColor: Colors.black,
                    title: Text('Vehicle issue'),
                    value: 4,
                    groupValue: groupValue,
                    onChanged: (int value) {
                      setState(() {
                        reason = "Vehicle issue";
                        groupValue = value;
                      });
                    }),
                RadioListTile(
                    activeColor: Colors.black,
                    title: Text('My reason is not listed'),
                    value: 5,
                    groupValue: groupValue,
                    onChanged: (int value) {
                      setState(() {
                        reason = "My reason is not listed";
                        groupValue = value;
                      });
                    }),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: RaisedButton(
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5.0),
                    ),
                    onPressed: () {
                      print("RideID" + widget.requestId);
                      if (reason != null) {
                        rideRef.doc(widget.requestId).update({
                          "status": "cancelled",
                          "CancellationReason": reason
                        });
                        FirebaseDatabase.instance
                            .reference()
                            .child("Ride Request")
                            .child(widget.requestId)
                            .child("status")
                            .set("cancelled");

                        rideStreamSubscription.cancel();

                        Navigator.pop(context);
                        Navigator.pop(context);

                        AssistantMethods.enableHomeTabLiveLocationUpdates();
                      } else {
                        Fluttertoast.showToast(
                            msg: "Please select the reason for cancellation");
                      }
                    },
                    color: Colors.black87,
                    child: Padding(
                      padding: EdgeInsets.all(17.0),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                )
              ]))),
    );
  }
}
