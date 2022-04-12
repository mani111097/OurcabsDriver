import 'dart:io';
import 'package:ourcabsdriver/notification/progress.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ourcabsdriver/Models/carlist.dart';
import 'package:ourcabsdriver/Models/driverdetails.dart';
import 'package:ourcabsdriver/tabs.dart';
import 'package:smart_select/smart_select.dart';
import 'package:image_cropper/image_cropper.dart';

class Detail extends StatefulWidget {
  DriverDetails driverDetails;

  Detail({this.driverDetails});

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  String dropdownValue = "Male";
  String dropdownValueCar = "Auto";
  String dropdownValueCarname = "";
  String cartype = "";
  String aurl, rcurl, lurl, purl, ppurl;
  String carname = "Car";

  bool rno1 = false, ppic = false, lno1 = false, ano1 = false, pno1 = false;

  TextEditingController name = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController phno = new TextEditingController();
  TextEditingController street = new TextEditingController();
  TextEditingController city = new TextEditingController();
  TextEditingController state = new TextEditingController();
  TextEditingController pin = new TextEditingController();
  TextEditingController cname = new TextEditingController();
  TextEditingController cmodel = new TextEditingController();
  TextEditingController ccolor = new TextEditingController();
  TextEditingController regno1 = new TextEditingController();
  TextEditingController regno2 = new TextEditingController();
  TextEditingController regno3 = new TextEditingController();
  TextEditingController regno4 = new TextEditingController();
  TextEditingController lno = new TextEditingController();
  TextEditingController ano = new TextEditingController();
  TextEditingController pno = new TextEditingController();
  double rating = 0.0;
  bool validate = false;

  double containerheight = 0.0;
  double colorContainer;

  final picker = ImagePicker();
  File _imageFile;
  int groupValue = 1;
  String reason;
  GlobalKey<FormState> _key = GlobalKey<FormState>();

  void pickImage(String type, BuildContext context) async {
    String selection;

    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150,
            child: Center(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) => Progressbar(
                              message: "Image is getting uploaded.Please wait",
                            ));
                    selection = "camera";
                    XFile image =
                        await picker.pickImage(source: ImageSource.camera);
                    setState(() {
                      _imageFile = File(image.path);
                    });

                    Fluttertoast.showToast(
                        msg: "Please wait till the image is uploaded");
                    Center(
                        child: Container(child: CircularProgressIndicator()));
                    String fileName = basename(_imageFile.path);
                    Reference ref = FirebaseStorage.instance.ref().child(
                        "${FirebaseAuth.instance.currentUser.phoneNumber}/$type");
                    UploadTask uploadTask = ref.putFile(_imageFile);
                    TaskSnapshot taskSnapshot = await uploadTask;
                    String imageURL = await taskSnapshot.ref.getDownloadURL();
                    if (type == "aadar") {
                      setState(() {
                        aurl = imageURL;
                      });
                    } else if (type == "RC") {
                      setState(() {
                        rcurl = imageURL;
                      });
                    } else if (type == "licence") {
                      setState(() {
                        lurl = imageURL;
                      });
                    } else if (type == "PAN") {
                      setState(() {
                        purl = imageURL;
                      });
                    }

                    Fluttertoast.showToast(
                        msg: "$type image has been updated successfully");
                    Navigator.of(context).pop();
                    //Navigator.of(context).pop();
                  },
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined),
                        Text("Camera")
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) => Progressbar(
                              message: "Image is getting uploaded.Please wait",
                            ));
                    final file =
                        await picker.pickImage(source: ImageSource.gallery);
                    selection = "gallery";
                    if (file != null) {
                      setState(() {
                        _imageFile = File(file.path);
                      });
                    }

                    String fileName = basename(_imageFile.path);
                    Reference ref = FirebaseStorage.instance.ref().child(
                        "${FirebaseAuth.instance.currentUser.phoneNumber}/$type");
                    UploadTask uploadTask = ref.putFile(_imageFile);
                    TaskSnapshot taskSnapshot = await uploadTask;
                    String imageURL = await taskSnapshot.ref.getDownloadURL();
                    print(imageURL);
                    Navigator.of(context).pop();
                    if (type == "aadar") {
                      setState(() {
                        aurl = imageURL;
                      });
                    } else if (type == "RC") {
                      setState(() {
                        rcurl = imageURL;
                      });
                    } else if (type == "licence") {
                      setState(() {
                        lurl = imageURL;
                      });
                    } else if (type == "PAN") {
                      setState(() {
                        purl = imageURL;
                      });
                    } else if (type == "Profile") {
                      setState(() {
                        ppurl = imageURL;
                      });
                    }
                    Navigator.of(context).pop();
                    Fluttertoast.showToast(
                        msg: "$type image has been updated successfully");
                  },
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.filter), Text("Gallery")],
                    ),
                  ),
                )
              ],
            )),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    phno.text = FirebaseAuth.instance.currentUser.phoneNumber;

    dropdowncarname() {
      return SmartSelect<String>.single(
        title: (cartype == "Auto" ? cartype : carname),
        placeholder: 'Select you car/Auto model',
        value: dropdownValueCarname,
        onChange: (selected) => setState(() {
          dropdownValueCarname = selected.value;
          cartype = selected.valueObject.subtitle;
          print(cartype);
          print(dropdownValueCarname);
          if (dropdownValueCarname == "Other") {
            containerheight = MediaQuery.of(context).size.height * 0.21;
          } else {
            containerheight = 0;
          }
          if (dropdownValueCarname == "Auto") {
            colorContainer = 0;
          } else {
            colorContainer = MediaQuery.of(context).size.height * 0.254;
          }
        }),
        choiceItems: S2Choice.listFrom<String, Map>(
            source: cars,
            value: (index, item) => item['value'],
            title: (index, item) => item['title'],
            group: (index, item) => item['brand'],
            subtitle: (index, item) => item['body']),
        choiceGrouped: true,
        choiceDivider: true,
        tileBuilder: (context, state) {
          return S2Tile(
            title: state.titleWidget,
            value: state.value,
            onTap: state.showModal,
            isTwoLine: true,
          );
        },
      );
    }

    dropdowncar() {
      return DropdownButton<String>(
        value: dropdownValueCar,
        icon: const Icon(Icons.arrow_drop_down),
        iconSize: 24,
        elevation: 16,
        style: const TextStyle(color: Colors.black),
        underline: Container(
          height: 2,
          color: Colors.grey,
        ),
        onChanged: (String newValue) {
          setState(() {
            dropdownValueCar = newValue;
          });
        },
        items: <String>['Auto', 'Sedan', 'SUV', "Mini"]
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Row(
              children: [
                Text(value),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                )
              ],
            ),
          );
        }).toList(),
      );
    }

    dropdown() {
      return DropdownButton<String>(
        value: dropdownValue,
        icon: const Icon(Icons.arrow_drop_down),
        iconSize: 24,
        elevation: 16,
        style: const TextStyle(color: Colors.black),
        underline: Container(
          height: 2,
          color: Colors.grey,
        ),
        onChanged: (String newValue) {
          setState(() {
            dropdownValue = newValue;
          });
        },
        items: <String>['Male', 'Female', 'Other']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Row(
              children: [
                Text(value),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                )
              ],
            ),
          );
        }).toList(),
      );
    }

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.07,
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      'Driver Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )),
              Container(
                padding: EdgeInsets.all(8),
                child: Form(
                  key: _key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            pickImage("Profile", context);
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.15,
                            width: MediaQuery.of(context).size.height * 0.15,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.fitWidth,
                                  image: (ppurl != null
                                      ? NetworkImage(ppurl)
                                      : AssetImage("images/profile.png"))),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          (ppic)
                              ? "Please upload the profile pic to continue"
                              : "",
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                      Text(
                        "Name:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextFormField(
                        controller: name,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          hintText: "Enter your Name",
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Name field cannot be null";
                          } else {
                            return null;
                          }
                        },
                        // errorText:
                        //     (name1 == true) ? "Name cant be Empty" : null),
                      ),
                      SizedBox(height: 15),
                      Text(
                        "Email Id:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextFormField(
                        controller: email,
                        decoration: InputDecoration(
                          hintText: "Enter your Email Id",
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Email cannot be empty";
                          } else {
                            if (value.contains("@") && value.contains(".com")) {
                              return "Invalid mail id";
                            } else {
                              return null;
                            }
                          }
                        },
                      ),
                      SizedBox(height: 15),
                      Text(
                        "Phone:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextFormField(
                        controller: phno,
                        decoration: InputDecoration(
                            hintText: "Enter your phone", enabled: false),
                      ),
                      SizedBox(height: 15),
                      Text(
                        "Gender:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: dropdown(),
                      ),
                      SizedBox(height: 15),
                      Text(
                        "Address:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextFormField(
                        controller: street,
                        decoration: InputDecoration(
                          hintText: "Street",
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Manditory field";
                          } else {
                            return null;
                          }
                        },
                      ),
                      TextFormField(
                        controller: city,
                        decoration: InputDecoration(
                          hintText: "City",
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Manditory field";
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: state,
                                decoration: InputDecoration(
                                  hintText: "State",
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Manditory field";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: pin,
                                maxLength: 6,
                                decoration: InputDecoration(
                                  hintText: "Pin Code (Ex: 560001)",
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Manditory field";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            )
                          ]),
                      SizedBox(height: 15),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.99,
                        child: dropdowncarname(),
                      ),
                      SizedBox(height: 15),
                      Container(
                        height: containerheight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Car Name:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextFormField(
                              controller: cmodel,
                              decoration: InputDecoration(
                                hintText:
                                    "Enter your Car Name Eg: i10,Alto, Dzire",
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Car Name cannot be empty";
                                } else {
                                  return null;
                                }
                              },
                            ),
                            SizedBox(height: 15),
                            Text(
                              "Car Type:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: dropdowncar(),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: colorContainer,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Car Color:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            TextFormField(
                              controller: ccolor,
                              decoration: InputDecoration(
                                hintText: "Enter your Car Color",
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Car Color cannot be empty";
                                } else {
                                  return null;
                                }
                              },
                            ),
                            SizedBox(height: 15),
                            Text(
                              "Are you willing to take outstation rides:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            RadioListTile(
                                activeColor: Colors.black,
                                title: Text("Yes"),
                                value: 1,
                                groupValue: groupValue,
                                onChanged: (int value) {
                                  setState(() {
                                    reason = "Y";
                                    groupValue = value;
                                  });
                                }),
                            RadioListTile(
                                activeColor: Colors.black,
                                title: Text("No"),
                                value: 2,
                                groupValue: groupValue,
                                onChanged: (int value) {
                                  setState(() {
                                    reason = "N";
                                    groupValue = value;
                                  });
                                }),
                          ],
                        ),
                      ),
                      Text(
                        "Registration Number:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 40,
                            child: TextFormField(
                                textCapitalization:
                                    TextCapitalization.characters,
                                textAlign: TextAlign.center,
                                controller: regno1,
                                maxLength: 2,
                                decoration: InputDecoration(
                                  hintText: "KA",
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Empty";
                                  } else {
                                    return null;
                                  }
                                }),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.06,
                          ),
                          SizedBox(
                            width: 40,
                            child: TextFormField(
                                textAlign: TextAlign.center,
                                controller: regno2,
                                maxLength: 2,
                                decoration: InputDecoration(
                                  hintText: "00",
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Empty";
                                  } else {
                                    return null;
                                  }
                                }),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.06,
                          ),
                          SizedBox(
                            width: 40,
                            child: TextFormField(
                                textCapitalization:
                                    TextCapitalization.characters,
                                textAlign: TextAlign.center,
                                controller: regno3,
                                maxLength: 2,
                                decoration: InputDecoration(
                                  hintText: "AA",
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Empty";
                                  } else {
                                    return null;
                                  }
                                }),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.06,
                          ),
                          SizedBox(
                            width: 70,
                            child: TextFormField(
                                textAlign: TextAlign.center,
                                controller: regno4,
                                maxLength: 4,
                                decoration: InputDecoration(
                                  hintText: "0000",
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Empty";
                                  } else {
                                    return null;
                                  }
                                }),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () => pickImage("RC", context),
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.07,
                            color: Colors.grey,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Upload RC book of the car",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.05),
                                Icon(
                                  Icons.upload,
                                  size: 40,
                                ),
                              ],
                            )),
                      ),
                      SizedBox(height: 5),
                      Text(
                        (rno1) ? "Please upload the document to continue" : "",
                        style: TextStyle(color: Colors.red[700]),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Licence Number:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextFormField(
                        controller: lno,
                        decoration: InputDecoration(
                          hintText: "Enter your Licence Number",
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Licence Number cannot be null";
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: 5),
                      GestureDetector(
                        onTap: () => pickImage("licence", context),
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.07,
                            color: Colors.grey,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Upload Licence Card",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.05),
                                Icon(
                                  Icons.upload,
                                  size: 40,
                                ),
                              ],
                            )),
                      ),
                      SizedBox(height: 5),
                      Text(
                        (lno1) ? "Please upload the document to continue" : "",
                        style: TextStyle(color: Colors.red[700]),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Aadar Number:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextFormField(
                          controller: ano,
                          maxLength: 16,
                          decoration: InputDecoration(
                            hintText: "Enter your Aadar Number",
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Aadar Number cannot be null";
                            } else if (value.length != 16) {
                              return "Invalid Aadar number";
                            } else {
                              return null;
                            }
                          }),
                      SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          pickImage("aadar", context);
                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.07,
                            color: Colors.grey,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Upload Aadhar Card",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.05),
                                Icon(
                                  Icons.upload,
                                  size: 40,
                                ),
                              ],
                            )),
                      ),
                      SizedBox(height: 5),
                      Text(
                        (ano1) ? "Please upload the document to continue" : "",
                        style: TextStyle(color: Colors.red[700]),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Pan Card Number:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextFormField(
                          controller: pno,
                          maxLength: 10,
                          decoration: InputDecoration(
                            hintText: "Enter your Pan card number",
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Pan Number cannot be null";
                            } else if (value.length != 10) {
                              return "Invalid PAN number";
                            } else {
                              return null;
                            }
                          }),
                      SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          pickImage("PAN", context);
                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.07,
                            color: Colors.grey,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Upload PAN Card",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.05),
                                Icon(
                                  Icons.upload,
                                  size: 40,
                                ),
                              ],
                            )),
                      ),
                      SizedBox(height: 5),
                      Text(
                        (pno1) ? "Please upload the document to continue" : "",
                        style: TextStyle(color: Colors.red[700]),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.07,
                          width: MediaQuery.of(context).size.height * 0.5,
                          child: RaisedButton(
                              onPressed: () {
                                if (_key.currentState.validate()) {
                                  print("validated");
                                }
                                if (rcurl == null) {
                                  setState(() {
                                    rno1 = true;
                                  });
                                } else {
                                  setState(() {
                                    rno1 = false;
                                  });
                                }
                                if (ppurl == null) {
                                  setState(() {
                                    ppic = true;
                                  });
                                } else {
                                  setState(() {
                                    ppic = false;
                                  });
                                }

                                if (aurl == null) {
                                  setState(() {
                                    ano1 = true;
                                  });
                                } else {
                                  setState(() {
                                    ano1 = false;
                                  });
                                }
                                if (purl == null) {
                                  setState(() {
                                    pno1 = true;
                                  });
                                } else {
                                  setState(() {
                                    pno1 = false;
                                  });
                                }
                                if (lurl == null) {
                                  setState(() {
                                    lno1 = true;
                                  });
                                } else {
                                  setState(() {
                                    lno1 = true;
                                  });
                                }
                                print("Validate" + lno1.toString());
                                print(aurl);
                                String rnumber = regno1.text +
                                    " " +
                                    regno2.text +
                                    " " +
                                    regno3.text +
                                    " " +
                                    regno4.text;
                                print(rnumber);
                                if (dropdownValueCarname == "Other") {
                                  setState(() {
                                    dropdownValueCarname =
                                        cname.text + "" + cmodel.text;
                                    cartype = dropdownValueCar;
                                  });
                                }

                                print(dropdownValueCar);
                                validation(
                                    name.text,
                                    email.text,
                                    phno.text,
                                    dropdownValue,
                                    street.text,
                                    city.text,
                                    state.text,
                                    pin.text,
                                    dropdownValueCarname,
                                    ccolor.text,
                                    cartype,
                                    rnumber,
                                    lno.text,
                                    ano.text,
                                    rating,
                                    pno.text,
                                    rcurl,
                                    aurl,
                                    lurl,
                                    purl,
                                    ppurl,
                                    reason,
                                    context);
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
                                  SizedBox(width: 10.0),
                                  Text(
                                    "Update",
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
            ],
          ),
        ),
      ),
    );
  }

  void validation(
      String name,
      String email,
      String phno,
      String dropdownValue,
      String street,
      String city,
      String state,
      String pin,
      String cname,
      String ccolor,
      String dropdownValueCar,
      String rno,
      String lno,
      String ano,
      double rating,
      String pno,
      String rcurl,
      String aurl,
      String lurl,
      String purl,
      String ppurl,
      String reason,
      BuildContext context) {
    Map<String, dynamic> data;
    if (name != null &&
        email != null &&
        email.contains("@") &&
        email.contains(".com") &&
        street != null &&
        city != null &&
        state != null &&
        pin != null &&
        cname != null &&
        rno != null &&
        lno != null &&
        ano != null &&
        pno != null &&
        aurl != null &&
        purl != null &&
        rcurl != null &&
        lurl != null &&
        ppurl != null) {
      if (cname == "Auto") {
        data = {
          "Name": name,
          "Email": email,
          "Phone": phno,
          "Gender": dropdownValue,
          "Rating": rating,
          "Address": {
            "Street": street,
            "City": city,
            "State": state,
            "PinCode": pin
          },
          "Car": {"CName": cname, "Rno": rno, "type": cartype},
          "Verification": {"Licence No": lno, "Aadar No": ano, "Pan No": pno},
          "URLs": {
            "RC book": rcurl,
            "Aadar": aurl,
            "Licence": lurl,
            "PAN": purl,
            "Profile": ppurl
          }
        };
      } else {
        data = {
          "Name": name,
          "Email": email,
          "Phone": phno,
          "Gender": dropdownValue,
          "Rating": rating,
          "Outstation": reason,
          "Address": {
            "Street": street,
            "City": city,
            "State": state,
            "PinCode": pin
          },
          "Car": {"CName": cname, "Rno": rno, "type": dropdownValueCarname},
          "Verification": {"Licence No": lno, "Aadar No": ano, "Pan No": pno},
          "URLs": {
            "RC book": rcurl,
            "Aadar": aurl,
            "Licence": lurl,
            "PAN": purl,
            "Profile": ppurl
          }
        };
      }

      User user = FirebaseAuth.instance.currentUser;
      FirebaseFirestore.instance
          .collection("Driver")
          .doc(user.phoneNumber)
          .set(data);

      Navigator.push(context, MaterialPageRoute(builder: (context) => Tabs()));
    } else {
      Fluttertoast.showToast(msg: "Please enter all the required feilds");
    }
  }
}
