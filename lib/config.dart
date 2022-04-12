import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ourcabsdriver/Models/drivers.dart';

String key = "AIzaSyCcRIKKftgSO8wKtV_LAVA-j_OEwADFzDs";

StreamSubscription<Position> homeTabPageStreamSubscription;

final assetsAudioPlayer = AssetsAudioPlayer();

User user;

Position currpost;

StreamSubscription<Position> rideStreamSubscription;

Drivers drivers;
String btnTitle ;
String status;
Color btnColor = Colors.black87;
bool isDriverAvailable = false;
BitmapDescriptor icon;
String OTP;


//cRoV-g76SOqs0F2CollqRu:APA91bGCHRwIHfvee4xqvagi6UIqgd2j8Cjw4S9_A7JWrdOSivVg13lfG4zsBNNRP9X5yYLhCvsB61GnMji0KjmJxRGFO5-_bk88Yl4px9zbC7fd7ny5iFYF5flrGNGSdVEK-u0ISF3g