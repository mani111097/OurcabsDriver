import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ourcabsdriver/Models/rideDetails.dart';
import 'package:ourcabsdriver/config.dart';
import 'package:ourcabsdriver/main.dart';
import 'package:ourcabsdriver/notification/notificationDialog.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
//import 'package:get/get.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message");
  assetsAudioPlayer.open(Audio("sound/car_chime.mp3"));
  assetsAudioPlayer.play();
}

class PushNotification {
  FirebaseMessaging firebasemessaging = FirebaseMessaging.instance;

  Future initialize(context) async {
    FirebaseMessaging.instance.getInitialMessage();

    FirebaseMessaging.onMessage.listen((event) async {
      retriveRideRequestInfo(getRideRequestId(event.data), context);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      //print(event);
      retriveRideRequestInfo(getRideRequestId(event.data), context);
      print("Handling a  message2: ${event.messageId}");
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<String> gettoken() async {
    String token = await firebasemessaging.getToken();
    print("This is token :: ");
    print(token);
    driversRef.child(user.uid).child("token").set(token);

    firebasemessaging.subscribeToTopic("alldrivers");
    firebasemessaging.subscribeToTopic("allusers");
  }

  String getRideRequestId(Map<String, dynamic> message) {
    String requestId = message['ride_request_id'];
    print("Requestid" + requestId);
    return requestId;
  }

  AndroidNotificationDetails androidPlatformChannel;

  void retriveRideRequestInfo(String requestId, BuildContext context) {
    print("retriveRideRequestInfo function called");

    newRequestRef.child(requestId).once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        assetsAudioPlayer.open(
          Audio("sound/car_chime.mp3"),
        );

        assetsAudioPlayer.play();

        double pickUpLocationLat =
            double.parse(dataSnapshot.value['pickup']['latitude'].toString());
        double pickUpLocationLng =
            double.parse(dataSnapshot.value['pickup']['longitude'].toString());
        String pickUpAddress = dataSnapshot.value['pickup_address'].toString();

        double dropOffLocationLat =
            double.parse(dataSnapshot.value['dropoff']['latitude'].toString());
        double dropOffLocationLng =
            double.parse(dataSnapshot.value['dropoff']['longitude'].toString());
        String dropOffAddress =
            dataSnapshot.value['dropoff_address'].toString();

        String paymentMethod = dataSnapshot.value['payment_method'].toString();
        String rider_phone = dataSnapshot.value["rider_phone"];
        String ride_date = dataSnapshot.value["created_at"];
        String requestorId = dataSnapshot.value["requestId"];
        String riderName = dataSnapshot.value["Name"];
        //String otp = dataSnapshot.value["otp"];

        RideDetails rideDetails = RideDetails();
        rideDetails.ride_request_id = requestId;
        rideDetails.rider_name = riderName;
        rideDetails.pickup_address = pickUpAddress;
        rideDetails.dropoff_address = dropOffAddress;
        rideDetails.pickup = LatLng(pickUpLocationLat, pickUpLocationLng);
        rideDetails.dropoff = LatLng(dropOffLocationLat, dropOffLocationLng);
        rideDetails.payment_method = paymentMethod;
        rideDetails.rider_phone = rider_phone;
        rideDetails.date = ride_date;
        rideDetails.requestId = requestorId;

        print(rideDetails);

        // flutterLocalNotificationsPlugin.show(
        //     0, "New Ride Request", dropOffAddress, platformChannelSpecifics,
        //     payload: 'Destination Screen()');

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => NotificationDialog(
                  rideDetails: rideDetails,
                ));
      }
    });
  }
}
