import 'package:flutter/material.dart';
import 'package:flutter_ticket_widget/flutter_ticket_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ourcabsdriver/Models/AssistantMethods.dart';
import 'package:ourcabsdriver/Models/rideDetails.dart';
import 'package:ourcabsdriver/Tabs/homescreen.dart';
import 'package:ourcabsdriver/config.dart';
import 'package:ourcabsdriver/main.dart';

class CollectFareDialog extends StatefulWidget {
  final String paymentMethod;
  final RideDetails rideDetails;
  final int fareAmount;

  CollectFareDialog({this.paymentMethod, this.fareAmount, this.rideDetails});

  @override
  _CollectFareDialogState createState() => _CollectFareDialogState();
}

class _CollectFareDialogState extends State<CollectFareDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FlutterTicketWidget(
          isCornerRounded: true,
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.5,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Text(
                    'Trip Fair',
                    style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                  ),
                  Divider(color: Colors.black),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                  ),
                  Text(
                    "₹ ${widget.fareAmount}",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 70,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.07,
                  ),
                  Text(
                    "This is the total trip amount, it has been charged to the rider.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: RaisedButton(
                      onPressed: () async {
                        status = "";
                        btnTitle = "";
                        Navigator.pop(context);
                        Navigator.pop(context);

                        AssistantMethods.enableHomeTabLiveLocationUpdates();
                      },
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(5.0),
                      ),
                      color: Colors.black,
                      child: Padding(
                        padding: EdgeInsets.all(17.0),
                        child: Text(
                          "Collect Cash",
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
