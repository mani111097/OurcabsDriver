import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ourcabsdriver/Tabs/earning.dart';
import 'package:ourcabsdriver/Tabs/homescreen.dart';
import 'package:ourcabsdriver/Tabs/profile.dart';

class Tabs extends StatefulWidget {
  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> with SingleTickerProviderStateMixin {
  TabController tabController;

  int selectedIndex = 0;

  void onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController.index = selectedIndex;
    });
  }

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController.dispose();
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          new GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: Text("NO"),
          ),
          SizedBox(
            width: 10,
          ),
          new GestureDetector(
            onTap: () => SystemNavigator.pop(),
            child: Text("YES"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: _onBackPressed,

      child: SafeArea(
        child: Scaffold(
          body: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: tabController,
              children: [Homescreen(), Earning(), Profile()]),
          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.credit_card),
                label: "Earnings",
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.star),
              //   label: "Ratings",
              // ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Account",
              ),
            ],
            unselectedItemColor: Colors.grey,
            selectedItemColor: Colors.black,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: TextStyle(fontSize: 12.0),
            showUnselectedLabels: true,
            currentIndex: selectedIndex,
            onTap: onItemClicked,
          ),
        ),
      ),
    );
  }
}
