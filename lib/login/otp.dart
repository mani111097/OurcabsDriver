import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:ourcabsdriver/login/detail.dart';
import 'package:ourcabsdriver/tabs.dart';

// ignore: must_be_immutable
class Otp extends StatefulWidget {
  String phone;
  Otp(this.phone);

  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  String verficationid, _pin;

  void initState() {
    otpgen();
    super.initState();
  }

  otpgen() {
    return _auth.verifyPhoneNumber(
        phoneNumber: widget.phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (credential) async {
          //Navigator.of(context).pop();

          var result = await _auth.signInWithCredential(credential);
          User user = result.user;

          if (user != null) {
            validation();
          } else {
            print("ERROR");
          }
        },
        verificationFailed: (verificationFailed) {
          print(verificationFailed);
        },
        codeSent: (verificationId, resendingToken) async {
          setState(() {
            verficationid = verificationId;
          });

          AuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verificationId, smsCode: widget.phone);

          var result = await _auth.signInWithCredential(credential);
          User user = result.user;

          if (user != null) {
            validation();
          } else {
            print("ERROR");
          }
        },
        codeAutoRetrievalTimeout: null,
        forceResendingToken: 1);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.07,
              ),
              Container(
                width: MediaQuery.of(context).size.height * 0.19,
                height: MediaQuery.of(context).size.height * 0.19,
                decoration: new BoxDecoration(
                  color: Colors.grey[900],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_unread_outlined,
                  color: Colors.redAccent,
                  size: MediaQuery.of(context).size.height * 0.11,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
              ),
              Text("Verification Code",
                  style: GoogleFonts.raleway(
                      fontSize: MediaQuery.of(context).size.height * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900])),
              Text("Please enter the verification code",
                  style: GoogleFonts.raleway(
                      fontSize: MediaQuery.of(context).size.height * 0.024,
                      color: Colors.grey[900])),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.raleway(
                      fontSize: MediaQuery.of(context).size.height * 0.024,
                      color: Colors.grey[900]),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'sent to ',
                    ),
                    TextSpan(
                        text: "${widget.phone}",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.015,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.07,
                  width: MediaQuery.of(context).size.width * 0.96,
                  child: OTPTextField(
                    length: 6,
                    width: MediaQuery.of(context).size.width,
                    textFieldAlignment: MainAxisAlignment.spaceAround,
                    fieldWidth: 55,
                    fieldStyle: FieldStyle.box,
                    outlineBorderRadius: 10,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.02),
                    onChanged: (pin) {
                      print("Changed: " + pin);
                    },
                    onCompleted: (pin) {
                      _pin = pin;
                    },
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.07,
                  width: MediaQuery.of(context).size.height * 0.49,
                  child: RaisedButton(
                      onPressed: () async {
                        //print("Button Pressed");

                        await FirebaseAuth.instance
                            .signInWithCredential(PhoneAuthProvider.credential(
                                verificationId: verficationid, smsCode: _pin))
                            .then((value) {
                          if (value.user != null) {
                            validation();
                          }
                        });
                      },
                      color: Colors.grey[900],
                      textColor: Colors.white,
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(18.0)),
                      child: Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //Icon(Icons.camera_alt_outlined),
                          SizedBox(
                              width:
                                  MediaQuery.of(context).size.height * 0.015),
                          Text(
                            "Verify your Phone Number",
                            style: GoogleFonts.raleway(
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void validation() {
    User user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection("Driver")
        .doc(user.phoneNumber)
        .get()
        .then((value) {
      if (value.data() != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Tabs()));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Detail()));
      }
    });
  }
}
