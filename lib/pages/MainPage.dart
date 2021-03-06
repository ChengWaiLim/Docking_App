import 'package:docking_project/Util/FlutterRouter.dart';
import 'package:docking_project/Util/UtilExtendsion.dart';
import 'package:docking_project/Widgets/StandardAppBar.dart';
import 'package:docking_project/pages/BookingListFragment.dart';
import 'package:docking_project/pages/NewBookingPage.dart';
import 'package:docking_project/pages/SettingFragment.dart';
import 'package:docking_project/pages/ShipmentFragment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_basecomponent/BaseRouter.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  PageController _pageViewcontroller = new PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        text: "Dock Booking System".tr(),
        fontColor: Colors.white,
        backgroundColor: UtilExtendsion.mainColor,
        trailingActions: [
          PlatformIconButton(
            onPressed: () => FlutterRouter().goToPage(context, Pages("FirstPage"), clear: true),
            icon: Icon(
              Icons.logout_outlined,
              color: Colors.white,
            ),
          )
        ],
      ),
      bottomNavigationBar: PlatformNavBar(
        currentIndex: _currentIndex,
        itemChanged: (index) => setState(
          () {
            _currentIndex = index;
            _pageViewcontroller.jumpToPage(index);
          },
        ),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.book_online_outlined), title: Text("New Booking".tr())),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), title: Text("Current Bookings".tr())),
          BottomNavigationBarItem(icon: Icon(Icons.settings), title: Text("Settings".tr())),
        ],
      ),
      body: SafeArea(
        child: PageView(
          onPageChanged: (index){
            setState(() {
              _currentIndex = index;
            });
          },
          controller: _pageViewcontroller,
          children: [
            // NewBookingFragment(),
            ShipmentFragment(),
            BookingListFragment(),
            SettingFragment()
          ],
        )
      ),
    );
  }
}
