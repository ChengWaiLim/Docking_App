import 'dart:convert';

import 'package:docking_project/Model/Booking.dart';
import 'package:docking_project/Model/Driver.dart';
import 'package:docking_project/Model/TimeSlot.dart';
import 'package:docking_project/Model/TruckType.dart';
import 'package:docking_project/Util/FlutterRouter.dart';
import 'package:docking_project/Util/Request.dart';
import 'package:docking_project/Util/UtilExtendsion.dart';
import 'package:docking_project/Widgets/CarTypePullDown.dart';
import 'package:docking_project/Widgets/CarTypeStandardField.dart';
import 'package:docking_project/Widgets/LicenseStandardTextField.dart';
import 'package:docking_project/Widgets/StandardAppBar.dart';
import 'package:docking_project/Widgets/StandardElevatedButton.dart';
import 'package:docking_project/Widgets/StandardPullDown.dart';
import 'package:docking_project/Widgets/TimeSlotGrid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_basecomponent/Util.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter_basecomponent/BaseRouter.dart';

class NewBookingPage extends StatefulWidget {
  final int warehouseID;
  final List<String> shipmentList;

  const NewBookingPage({Key key, this.warehouseID, this.shipmentList})
      : super(key: key);

  @override
  _NewBookingPageState createState() => _NewBookingPageState();
}

class _NewBookingPageState extends State<NewBookingPage> {
  final TextEditingController licenseTextController = TextEditingController();
  final TextEditingController remarkTextController = TextEditingController();
  final _carTypeKey = GlobalKey<CarTypePullDownState>();
  final _dateSelectorKey = GlobalKey<StandardPullDownState>();
  final _formKey = GlobalKey<FormState>();
  List<PickerItem> truckTypeSelection;
  List<PickerItem> dateSelection = [];
  List<TruckType> truckTypeList;
  List<dynamic> dateList;
  List<TimeSlot> timeSlotList = [];
  TimeSlot selectedTimeSlot;
  Driver driver;
  int selectedTimeSlotIndex = -1;
  String selectedTime;
  Future futureBuilder;
  ValueNotifier<GlobalKey<CarTypePullDownState>> carTypeValueNotifier;

  @override
  void initState() {
    futureBuilder = getInformation();
    super.initState();
    carTypeValueNotifier = ValueNotifier(_carTypeKey);
  }

  int _getTimeSlotUsageByValue(String value) {
    return this
        .truckTypeList
        .firstWhere((element) => element.truck_Type == value)
        .timeSlot_Usage;
  }

  Future<void> getInformation() async {
    try {
      this.truckTypeList = await Request()
          .getTrunckTypeByWarehouseID(context, widget.warehouseID);
      driver = await Request().getDriver(context: context);
      if (driver.default_Truck_Type != null &&
          driver.default_Truck_Type.isNotEmpty)
        await _getDateSelection(driver.default_Truck_Type);
      this.truckTypeSelection =
          UtilExtendsion.getTruckTypeSelection(this.truckTypeList);
      licenseTextController.text = driver.default_Truck_No;
    } catch (e) {
      throw e;
    }
  }

  Future<void> _getDateSelection(String truckType) async {
    this.dateList =
        await Request().getTimeSlot(context, widget.warehouseID, truckType);
    this.dateSelection = this
        .dateList
        .map((e) => new PickerItem(
            text: Text(DateFormat("yyyy-MM-dd")
                .format(DateTime.parse(e["bookingDate"].substring(0, 10)))),
            value: e["bookingDate"]))
        .toList();
  }

  void getTimeSlot(List<dynamic> dateList) {
    try {
      List<dynamic> list = dateList.firstWhere((element) =>
          element["bookingDate"] ==
          _dateSelectorKey.currentState.selectedValue)["bookingTimeSlots"];
      this.timeSlotList = list.map((e) => new TimeSlot.fromJson(e)).toList();
    } catch (error) {
      this.timeSlotList = [];
    }
  }

  void submitBooking() async {
    if (_formKey.currentState.validate()) {
      try {
        Util.showLoadingDialog(context);
        if (widget.warehouseID == null) throw "Please Select Warehouse".tr();
        if (driver.driver_ID == null || driver.driver_ID.isEmpty)
          throw "Driver ID Cannot Be Empty".tr();
        if (driver.tel == null || driver.tel.isEmpty)
          throw "Mobile Number Cannot Be Empty".tr();
        if (licenseTextController.text == null ||
            licenseTextController.text.isEmpty)
          throw "License Cannot Be Empty".tr();
        if (_carTypeKey.currentState.selectedValue == null ||
            _carTypeKey.currentState.selectedValue.isEmpty)
          throw "Car Type Cannot Be Empty".tr();
        if (!_carTypeKey.currentState.isAnswerValid() || _dateSelectorKey.currentState.selectedValue == null ||
            _dateSelectorKey.currentState.selectedValue.isEmpty )
          throw "Booking Date Cannot Be Empty".tr();
        if (selectedTime == null || selectedTime.isEmpty)
          throw "Booking Time Slot Cannot Be Empty".tr();
        Navigator.pop(context);
        FlutterRouter().goToPage(context, Pages("ConfirmBookingPage"),
            parameters: "/" + _carTypeKey.currentState.selectedLabel,
            routeSettings: RouteSettings(arguments: {
              "booking": new Booking(
                  warehouseID: widget.warehouseID,
                  shipmentList: widget.shipmentList,
                  driverID: driver.driver_ID,
                  driverCountryCode: driver.countryCode,
                  driverTel: driver.tel,
                  truckNo: licenseTextController.text,
                  truckType: _carTypeKey.currentState.selectedValue,
                  bookingDate: _dateSelectorKey.currentState.selectedValue,
                  timeSlot: selectedTime,
                  timeSlotUsage: _getTimeSlotUsageByValue(
                      _carTypeKey.currentState.selectedValue)),
              "timeSlot": selectedTimeSlot
            }));
      } catch (error) {
        Navigator.pop(context);
        Util.showAlertDialog(context, error.toString());
      }
    }
  }

  void _clearDateSelection() {
    setState(() {
      if (_dateSelectorKey.currentState != null)
        _dateSelectorKey.currentState.setValue(null);
      this.timeSlotList = [];
      selectedTimeSlot = null;
      selectedTimeSlotIndex = -1;
      selectedTime = null;
    });
  }

  Widget _timeSlotSelectPart(StateSetter setState) {
    return Column(
      children: [
        StandardPullDown(
          hintText: "Please Select Booking Date Time".tr(),
          key: _dateSelectorKey,
          pickerList: dateSelection,
          onSelected: (value, String displayLabel) {
            setState(() {
              selectedTimeSlot = null;
              getTimeSlot(this.dateList);
              selectedTimeSlotIndex = -1;
              selectedTime = null;
            });
          },
        ),
        SizedBox(
          height: Util.responsiveSize(context, 32),
        ),
        Text(
          "Available Time Slots".tr(),
          style: TextStyle(fontSize: Util.responsiveSize(context, 28)),
        ),
        SizedBox(
          height: Util.responsiveSize(context, 32),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: TimeSlotGrid(
            selectedIndex: selectedTimeSlotIndex,
            timeSlotList: this.timeSlotList,
            onSelected:
                (int index, TimeSlot selectedTimeSlot, String timeSlotText) {
              setState(() {
                selectedTimeSlotIndex = index;
                selectedTime = selectedTimeSlot.timeSlotId;
                this.selectedTimeSlot = selectedTimeSlot;
              });
            },
          ),
        ),
        SizedBox(height: Util.responsiveSize(context, 18),),
        StandardElevatedButton(
          backgroundColor: UtilExtendsion.mainColor,
          text: "Next".tr(),
          onPress: (){

          },
        ),
      ],
    );
  }

  bool _isTruckTypeValid() {
    return (_carTypeKey.currentState != null &&
        _carTypeKey.currentState.isAnswerValid());
  }

    Widget _remarkField(BuildContext context) {
    double size = 18;
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: Util.responsiveSize(context, size)),
      child: Column(
        children: [
          SizedBox(
            height: Util.responsiveSize(context, 8),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                    "Remark".tr() + ":",
                    style: TextStyle(
                        color: Color(0xff888888),
                        fontSize: Util.responsiveSize(context, size)),
                  ),
                  SizedBox(
                    width: Util.responsiveSize(context, 8),
                  ),
              Expanded(child: TextField(controller: remarkTextController,))
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        text: "Create New Booking".tr(),
        backgroundColor: UtilExtendsion.mainColor,
        fontColor: Colors.white,
      ),
      body: FutureBuilder(
        future: futureBuilder,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          return UtilExtendsion.CustomFutureBuild(context, snapshot, () {
            return GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: Util.responsiveSize(context, 32),
                        ),
                        CarTypePullDown(
                            initValue: driver.default_Truck_Type,
                            truckTypeSelection: truckTypeSelection,
                            key: _carTypeKey,
                            onSelected: (String selectedValue,String displayLabel) async {
                              try{
                                Util.showLoadingDialog(context);
                                await _getDateSelection(_carTypeKey.currentState.selectedValue);
                                _clearDateSelection();
                                Navigator.pop(context);
                                Util.showModalSheet(context, "Booking Date".tr(), (BuildContext context, StateSetter setState){
                                  return _timeSlotSelectPart(setState);
                                }, colorTone: UtilExtendsion.mainColor);
                              }catch(error){
                                Navigator.pop(context);
                                Util.showAlertDialog(context, error.toString());
                              }
                            }),
                        SizedBox(
                          height: Util.responsiveSize(context, 24),
                        ),
                        LicenseStandardTextField(
                          textController: licenseTextController,
                        ),
                        SizedBox(
                          height: Util.responsiveSize(context, 24),
                        ),
                        _remarkField(context),
                        SizedBox(
                          height: Util.responsiveSize(context, 8),
                        ),
                        Divider(
                          color: Colors.black,
                        ),
                        SizedBox(
                          height: Util.responsiveSize(context, 8),
                        ),
                        // ValueListenableBuilder(
                        //   valueListenable: carTypeValueNotifier,
                        //   builder: (context, GlobalKey<CarTypePullDownState> value, _) {
                        //     if(value.currentState != null && value.currentState.isAnswerValid()){
                        //       return _timeSlotSelectPart();
                        //     }
                        //     return SizedBox();
                        //   },
                        // ),
                        SizedBox(
                          height: Util.responsiveSize(context, 18),
                        ),
                        // StandardElevatedButton(
                        //   backgroundColor: UtilExtendsion.mainColor,
                        //   text: "Next".tr(),
                        //   onPress: () => submitBooking(),
                        // ),
                        // SizedBox(
                        //   height: Util.responsiveSize(context, 24),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
