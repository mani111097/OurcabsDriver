import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ourcabsdriver/Models/rideDetails.dart';
import 'package:ourcabsdriver/config.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:ourcabsdriver/login/login.dart';
import 'package:ourcabsdriver/notification/notificationDialog.dart';
import 'package:ourcabsdriver/notification/pushnotification.dart';
import 'package:ourcabsdriver/tabs.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("background handler called");
//   await Firebase.initializeApp();
//   //String requestId = message.data['ride_request_id'];

//   assetsAudioPlayer.open(Audio("sound/car_chrime.mp3"));
//   assetsAudioPlayer.play();
// }




AndroidNotificationChannel channel = AndroidNotificationChannel(
    "id", "name", "description",
    playSound: true,
    sound: RawResourceAndroidNotificationSound('car_chime'),
    importance: Importance.high);

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      .createNotificationChannel(channel);

  runApp(MyApp());
}

DatabaseReference rideRequestRef = FirebaseDatabase.instance
    .reference()
    .child("Drivers")
    .child(user.uid)
    .child("newRide");

CollectionReference rideRef =
    FirebaseFirestore.instance.collection("Ride Request");

DatabaseReference driversRef =
    FirebaseDatabase.instance.reference().child("Drivers");

DatabaseReference newRequestRef =
    FirebaseDatabase.instance.reference().child("Ride Request");

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    
    if (icon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(1, 1));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/marker.png")
          .then((value) {
        icon = value;
      });
    }
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? 'login' : 'home',
      routes: {'login': (context) => Login(), 'home': (context) => Tabs()},
    );
  }
}
