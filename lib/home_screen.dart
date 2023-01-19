import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:restart_app/restart_app.dart';
import 'package:url_launcher/url_launcher.dart';

import 'background_screen.dart';
import 'controller.dart';
import 'foreground_screen.dart';
import 'models.dart';

var firstTime = true;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer timer;
  late Prayer nextPrayer = Prayer("s", "تقبل الله طاعتكم", false);
  late Prayer? currentPrayer = Prayer("s", "s", false);
  late String reminderTime = "";
  bool visiblityLoader = true;
  var handlerError = false;

  @override
  void initState() {
    super.initState();
    updatePrayers(() {
      showDialog(
          context: context,
          builder: (_) =>  AlertDialog(
                title: const Text(
                  "Change location",
                  style: TextStyle(fontSize: 18),
                ),
                content: const Text("Your location has been changed \npress refresh to reset data",
                    style: TextStyle(fontSize: 12)),
                actions: [
                  TextButton(
                      onPressed: () {
                        Restart.restartApp(webOrigin: '[your main route]');
                      },
                      child: const Text(
                        "Refresh",
                        style: TextStyle(color: Color(0xffE26B26)),
                      ))
                ],
                elevation: 22,
              ),
          barrierDismissible: false);
    }).then((value) {
      List<Prayer> newPrayers = [];
      for (var element in value) {
        if (element.title == "Imsak" || element.title == "Sunset") {
        } else {
          if (element.title == "Fajr") element.title = "الفجر";
          if (element.title == "Sunrise") element.title = "الشروق";
          if (element.title == "Dhuhr") element.title = "الظهر";
          if (element.title == "Asr") element.title = "العصر";
          if (element.title == "Maghrib") element.title = "المغرب";
          if (element.title == "Isha") element.title = "العشاء";
          element.time = element.time.substring(0, 5);
          newPrayers.add(element);
        }
      }

      prayers = newPrayers;

      nextPrayer = getNextPrayer()!;
      if (nextPrayer.status == "now") currentPrayer = nextPrayer;

      for (var element in prayers) {
        if (element.selected) currentPrayer = element;
      }
      reminderTime = calculateRemindTime(nextPrayer);

      setState(() => visiblityLoader = false);

      //Update state every mint
      timer = Timer.periodic(const Duration(minutes: 1), (Timer t) => update());
    }).catchError((e) {
      print("Eeeeeeeeeeeeeeeeeee $e");
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                title: Text(
                  "Bad internet",
                  style: TextStyle(fontSize: 18),
                ),
                content: Text("No Internet connect \ncheck your internet and try again", style: TextStyle(fontSize: 12)),
                elevation: 22,
              ),
          barrierDismissible: false);
    });
  }

  var firstUpdate = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            BackGroundWidget(currentPrayer),
            ForeGroundWidget(nextPrayer, reminderTime, currentPrayer),
            Container(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                child: Container(
                  width: double.infinity,
                  height: 35,
                  decoration: const BoxDecoration(
                      color: Color(0xcd195251),
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                  child: const Icon(
                    Icons.keyboard_arrow_up_outlined,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
                onTap: () {
                  showCupertinoModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) => Material(
                      color: Colors.transparent,
                      child: Container(
                        height: MediaQuery.of(context).size.height / 1.5,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40.0), topRight: Radius.circular(40.0))),
                        child: SingleChildScrollView(
                          child: Stack(
                            alignment: AlignmentDirectional.topCenter,
                            children: [
                              Container(
                                  height: 450,
                                  alignment: Alignment.bottomRight,
                                  transform: Matrix4.translationValues(100, 270, 0.0),
                                  child: Opacity(
                                    opacity: 0.8,
                                    child: RotatedBox(
                                      quarterTurns: 1,
                                      child: Image.asset(
                                        "assets/Asset 2.png",
                                        color: const Color(0xffE26B26).withOpacity(0.3),
                                      ),
                                    ),
                                  )),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 15),
                                  Image.asset('assets/Logo_Original.png', width: 172, height: 92),
                                  const SizedBox(height: 18),
                                  const Text("تطبيق ميقاتي لمواعيد الصلاة"),
                                  const Text("تقبل الله طاعتكم"),
                                  const Text("تم تصميم  و تطوير التطبيق من قبل شركة"),
                                  const Text("Sky Services Group", style: secondTextStyle),
                                  const Text("المختصة بتطوير التطبيقات و مواقع الويب و الاستضافة"),
                                  const SizedBox(height: 12),
                                  const Text("لمعرفة المزيد زورو موقعنا"),
                                  const SizedBox(height: 5),
                                  InkWell(
                                    child: Text("www.ssg-tech.com", style: TextStyle(color: Color(0xffE26B26),fontSize: 15)),
                                    onTap: () async {
                                      log("Click me now !!!!!!!");
                                      await launch('https://www.ssg-tech.com');
                                    },
                                  ),
                                  const SizedBox(height: 18),
                                  const Text("للتواصل معنا",
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  RichText(
                                    text: TextSpan(children: [
                                      const WidgetSpan(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                                          child: Icon(
                                            Icons.email,
                                            color: Color(0xffE26B26),
                                          ),
                                        ),
                                      ),
                                      TextSpan(
                                          text: "info@ssg-tech.com",
                                          style: const TextStyle(color: Colors.black),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              await launch("mailto:info@ssg-tech.com");
                                            }),
                                    ]),
                                  ),
                                  const SizedBox(height: 14),
                                  RichText(
                                    text: TextSpan(children: [
                                      const WidgetSpan(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                                          child: Icon(Icons.whatsapp, color: Color(0xffE26B26)),
                                        ),
                                      ),
                                      TextSpan(
                                          text: "+963 955 310 484",
                                          style: const TextStyle(color: Colors.black),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              await launch("tel:+963-955-310-484");
                                            }),
                                    ]),
                                  ),
                                  const SizedBox(height: 14),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        const WidgetSpan(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Icon(Icons.phone, color: Color(0xffE26B26)),
                                          ),
                                        ),
                                        TextSpan(
                                            text: "+963 11 3310 484",
                                            style: const TextStyle(color: Colors.black),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () async {
                                                await launchUrl(Uri.parse("tel:+963-11-310-484"));
                                              }),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Visibility(
                visible: visiblityLoader,
                child: Container(
                    color: Colors.white54,
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(color: const Color(0xFFE26B26)))),
          ],
        ),
      ),
    );
  }

  void update() {
    setState(() {
      firstTime = false;
      nextPrayer = getNextPrayer()!;
      if (nextPrayer.status == "now") currentPrayer = nextPrayer;
      for (var element in prayers) {
        if (element.selected) currentPrayer = element;
      }
      reminderTime = calculateRemindTime(nextPrayer);
      print(
          "Update now with next prayer${nextPrayer.title} current prayer ${currentPrayer?.title} reminded time $reminderTime");
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}

const secondTextStyle = TextStyle(color: Color(0xffE26B26));
