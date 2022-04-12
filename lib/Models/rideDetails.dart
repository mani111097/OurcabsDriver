import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideDetails {
  String rider_name;
  String pickup_address;
  String dropoff_address;
  LatLng pickup;
  LatLng dropoff;
  String ride_request_id;
  String payment_method;
  String rider_phone;
  String date;
  String otp;
  String requestId;
  String status;

  RideDetails(
      {this.pickup_address,
      this.dropoff_address,
      this.pickup,
      this.dropoff,
      this.ride_request_id,
      this.payment_method,
      this.rider_phone,
      this.otp,
      this.date,
      this.requestId,this.status});
}
