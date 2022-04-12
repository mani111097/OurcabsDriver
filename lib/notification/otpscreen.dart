import 'package:flutter/material.dart';
import 'package:ourcabsdriver/Models/rideDetails.dart';
import 'package:ourcabsdriver/main.dart';
import 'package:ourcabsdriver/notification/newRideScreen.dart';

class OtpScreen extends StatefulWidget {
  String requestId;
  OtpScreen({this.requestId});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController otpcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          margin: EdgeInsets.all(10.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Enter the OTP",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              SizedBox(height: 10),
              Container(
                width: 40,
                child: TextField(
                  controller: otpcontroller,
                  keyboardType: TextInputType.number,
                ),
              ),
              RaisedButton(
                color: Colors.black54,
                onPressed: () {
                  print('Ride Otp' + widget.requestId.toString());
                  if (otpcontroller.text == widget.requestId.toString()) {
                    Navigator.pop(context, 'start');
                  }
                },
                child: Text("Start the trip"),
              )
            ],
          ),
        ));
  }
}
