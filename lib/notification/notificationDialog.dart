import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ourcabsdriver/Models/AssistantMethods.dart';
import 'package:ourcabsdriver/Models/rideDetails.dart';
import 'package:ourcabsdriver/config.dart';
import 'package:ourcabsdriver/main.dart';
import 'package:ourcabsdriver/notification/newRideScreen.dart';

class NotificationDialog extends StatelessWidget {
  final RideDetails rideDetails;
  NotificationDialog({this.rideDetails});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Colors.transparent,
      elevation: 1.0,
      child: Container(
        margin: EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10.0),
            // Image.asset(
            //   "images/uberx.png",
            //   width: 150.0,
            // ),
            SizedBox(
              height: 0.0,
            ),
            Text(
              "New Ride Request",
              style: TextStyle(
                fontFamily: "Brand Bold",
                fontSize: 20.0,
              ),
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: EdgeInsets.all(18.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_history_rounded),
                      SizedBox(
                        width: 20.0,
                      ),
                      Expanded(
                        child: Container(
                            child: Text(
                          rideDetails.pickup_address,
                          style: TextStyle(fontSize: 18.0),
                        )),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_history_rounded),
                      SizedBox(
                        width: 20.0,
                      ),
                      Expanded(
                          child: Container(
                              child: Text(
                        rideDetails.dropoff_address,
                        style: TextStyle(fontSize: 18.0),
                      ))),
                    ],
                  ),
                  SizedBox(height: 0.0),
                ],
              ),
            ),
            SizedBox(height: 15.0),
            Divider(
              height: 2.0,
              thickness: 4.0,
            ),
            SizedBox(height: 0.0),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.red)),
                    color: Colors.white,
                    textColor: Colors.red,
                    padding: EdgeInsets.all(8.0),
                    onPressed: () {
                      assetsAudioPlayer.stop();
                      Navigator.pop(context);
                      //flutterLocalNotificationsPlugin.cancel(0);
                    },
                    child: Text(
                      "Cancel".toUpperCase(),
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  SizedBox(width: 25.0),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.green)),
                    onPressed: () {
                      status = "accepted";
                      assetsAudioPlayer.stop();
                      print("Accept");
                      checkAvailabilityOfRide(context);
                      //flutterLocalNotificationsPlugin.cancel(0);
                    },
                    color: Colors.green,
                    textColor: Colors.white,
                    child: Text("Accept".toUpperCase(),
                        style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 0.0),
          ],
        ),
      ),
    );
  }

  void checkAvailabilityOfRide(context) {
    FirebaseDatabase.instance
        .reference()
        .child("Drivers")
        .child(user.uid)
        .child("newRide")
        .once()
        .then((DataSnapshot dataSnapShot) {
      Navigator.pop(context);
      String theRideId = "";
      if (dataSnapShot.value != null) {
        theRideId = dataSnapShot.value.toString();
        print("RideId" + theRideId);
      } else {
        Fluttertoast.showToast(msg: "Ride doesnot exists.");
      }

      if (theRideId == rideDetails.ride_request_id) {
        FirebaseDatabase.instance
            .reference()
            .child("Drivers")
            .child(user.uid)
            .child("newRide")
            .set("accepted");
        AssistantMethods.disableHomeTabLiveLocationUpdates();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewRideScreen(rideDetails: rideDetails)));
      } else if (theRideId == "cancelled") {
        Fluttertoast.showToast(
          msg: "Ride has been Cancelled.",
        );
      } else if (theRideId == "timeout") {
        Fluttertoast.showToast(
          msg: "Ride has time out.",
        );
      } else {
        Fluttertoast.showToast(
          msg: "Ride not exists.",
        );
      }
    });
  }
}
