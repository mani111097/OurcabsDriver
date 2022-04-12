import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ourcabsdriver/Models/DirectionDetails.dart';
import 'package:ourcabsdriver/config.dart';
import 'package:http/http.dart' as http;
import 'package:ourcabsdriver/notification/pushnotification.dart';

class AssistantMethods {
  static Future<DirectionDetails> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$key";

    // var res = await RequestAssistance.getRequest(directionUrl);
    // print("Direction1:" + res.toString());

    Uri uri = Uri.parse(directionUrl);
    http.Response response = await http.get(uri);
    var decodedata;

    try {
      if (response.statusCode == 200) {
        String jsondata = response.body;
        decodedata = jsonDecode(jsondata);

        print("Decodedata: " + decodedata.toString());
        //   return decodedata;
        // } else {
        //   return "FAILED";
      }
    } catch (exp) {
      return exp;
    }

    // if (decodedata == "FAILED") {
    //   return null;
    // }

    print("Direction2:" + decodedata.toString());

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints =
        decodedata["routes"][0]["overview_polyline"]["points"];

    print("EncodedPoints" +
        decodedata["routes"][0]["overview_polyline"]["points"].toString());

    directionDetails.distanceText =
        decodedata["routes"][0]["legs"][0]["distance"]["text"];
    print("distanceText" +
        decodedata["routes"][0]["legs"][0]["distance"]["text"].toString());
    directionDetails.distanceValue =
        decodedata["routes"][0]["legs"][0]["distance"]["value"];

    print("distanceValue" +
        decodedata["routes"][0]["legs"][0]["distance"]["value"].toString());

    directionDetails.durationText =
        decodedata["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue =
        decodedata["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  static int calculateFares(DirectionDetails directionDetails, String type) {
    double fair;
    double accessfee = 20.0;
    double minifair = 30.0;

    if (directionDetails != null) {
      double timeTraveledFare = (directionDetails.durationValue / 60) * 0.20;
      double traveldis = directionDetails.distanceValue / 1000;
      if (type == "Auto") {
        if (traveldis <= 2.0) {
          fair = minifair + accessfee + timeTraveledFare;
          return fair.truncate();
        } else {
          double extrakm = (traveldis - 2.0) * 15;
          fair = minifair + accessfee + extrakm + timeTraveledFare;

          return fair.truncate();
        }
      }
      if (type == "Mini") {
        fair = (traveldis * 19) + accessfee + minifair + timeTraveledFare;

        return fair.truncate();
      }
      if (type == "Sedan") {
        fair = (traveldis * 24) + accessfee + minifair + timeTraveledFare;

        return fair.truncate();
      }
      if (type == "SUV") {
        fair = (traveldis * 35) + accessfee + minifair + timeTraveledFare;

        return fair.truncate();
      }
    } else {
      return null;
    }
    //in terms USD
  }

  static void disableHomeTabLiveLocationUpdates() {
    homeTabPageStreamSubscription.pause();
    Geofire.removeLocation(user.uid);
  }

  static void enableHomeTabLiveLocationUpdates() async {
    homeTabPageStreamSubscription.resume();
    Geofire.setLocation(user.uid, currpost.latitude, currpost.longitude);
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currpost = position;

    Geofire.initialize("availableDrivers");
    Geofire.setLocation(user.uid, currpost.latitude, currpost.longitude);

    FirebaseFirestore.instance
        .collection("Driver")
        .doc(user.uid)
        .collection("User Details")
        .doc("User Details")
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
      // FirebaseDatabase.instance
      //     .reference()
      //     .child("Drivers")
      //     .child(user.uid)
      //     .update(value.data()['Name']);
    });
  }

  // static void retrieveHistoryInfo(context)
  // {
  //   //retrieve and display Earnings
  //   driversRef.child(user.uid).child("earnings").once().then((DataSnapshot dataSnapshot)
  //   {
  //     if(dataSnapshot.value != null)
  //     {
  //       String earnings = dataSnapshot.value.toString();
  //       Provider.of<AppData>(context, listen: false).updateEarnings(earnings);
  //     }
  //   });

  //   //retrieve and display Trip History
  //   driversRef.child(user.uid).child("history").once().then((DataSnapshot dataSnapshot)
  //   {
  //     if(dataSnapshot.value != null)
  //     {
  //       //update total number of trip counts to provider
  //       Map<dynamic, dynamic> keys = dataSnapshot.value;
  //       int tripCounter = keys.length;
  //       Provider.of<AppData>(context, listen: false).updateTripsCounter(tripCounter);

  //       //update trip keys to provider
  //       List<String> tripHistoryKeys = [];
  //       keys.forEach((key, value) {
  //         tripHistoryKeys.add(key);
  //       });
  //       Provider.of<AppData>(context, listen: false).updateTripKeys(tripHistoryKeys);
  //       obtainTripRequestsHistoryData(context);
  //     }
  //   });
  // }

  // static void obtainTripRequestsHistoryData(context)
  // {
  //   var keys = Provider.of<AppData>(context, listen: false).tripHistoryKeys;

  //   for(String key in keys)
  //   {
  //     newRequestRef.child(key).once().then((DataSnapshot snapshot) {
  //       if(snapshot.value != null)
  //       {
  //         var history = History.fromSnapshot(snapshot);
  //         Provider.of<AppData>(context, listen: false).updateTripHistoryData(history);
  //       }
  //     });
  //   }
  // }

  // static String formatTripDate(String date)
  // {
  //   DateTime dateTime = DateTime.parse(date);
  //   String formattedDate = "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";

  //   return formattedDate;
  // }
}
