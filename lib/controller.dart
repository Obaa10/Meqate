import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:meqate/models.dart';
import 'package:meqate/time_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

var prayers = [
  Prayer("00:00", "الفجر", false),
  Prayer("00:00", "الشروق", false),
  Prayer("00:00", "الظهر", false),
  Prayer("00:00", "العصر", false),
  Prayer("00:00", "المغرب", false),
  Prayer("00:00", "لعشاء", false),
];

Prayer? getNextPrayer() {
  DateTime now = DateTime.now();

  Prayer myPrayer = prayers[0];
  var index = 0;
  for (var element in prayers) {
    index++;
    element.selected = false;
    if (intFromTime(DateFormat("HH:mm").parse(element.time)) > intFromTime(now)) {
      //Upcoming prayer
      myPrayer = element;
      break;
    } else if (intFromTime(DateFormat("HH:mm").parse(element.time)) == intFromTime(now)) {
      //Current prayer
      myPrayer = element;
      myPrayer.status = "now";
      break;
    } else {
      //Last prayer
      myPrayer = element;
      myPrayer.status = "final";
      prayers[index - 1].selected = false;
    }
  }
  if (index != 1) {
    prayers[index - 2].selected = true;
  }
  return myPrayer;
}

String calculateRemindTime(Prayer prayer) {
  //now, upcoming, final
  DateTime now = DateTime.now();
  if (prayer.status == "now") {
    return "حان الآن وعد صلاة";
  } else if (prayer.status == "upcoming") {
    var remindTime = intFromTime(DateFormat("HH:mm").parse(prayer.time)) - intFromTime(now);
    return " تبقى ${durationToString(remindTime)} لصلاة ";
  } else {
    return "تقبل الله طاعتكم";
  }
}

Future<Map<String, dynamic>> getCountry() async {
  return jsonDecode((await http.get(Uri.parse("http://ip-api.com/json"))).body);
}

/// Get all prayers in this month
Future<List<PrayerDate>> getAllData() async {
  var dateNow = DateTime.now();
  List<PrayerDate> allPrayersForMonth = [];
  var prefs = await SharedPreferences.getInstance();

  final uri = Uri.parse('https://api.aladhan.com/v1/calendarByCity').replace(queryParameters: {
    'city': prefs.get('city') ?? "Damascus",
    'country': prefs.get('country') ?? "Syria",
    'month': dateNow.month.toString(),
    'year': dateNow.year.toString(),
  });

  final response = await http.get(uri);
  await prefs.setString("prayers_month", dateNow.month.toString());
  allPrayersForMonth.addAll(fromJson(jsonDecode(response.body)));

  return allPrayersForMonth;
}

List<PrayerDate> fromJson(Map<String, dynamic> json) {
  var prayers = json["data"] as List<dynamic>;
  return prayers.map((e) => PrayerDate.fromJson(e as Map<String, dynamic>)).toList();
}

/// Get all prayer in this day from cache or from internet.
Future<List<Prayer>> updatePrayers(Function() changeLocation) async {
  var prefs = await SharedPreferences.getInstance();
  String? prayerJs;
  Map<String, dynamic> location = {'n': "s"};
  if (prefs.get('city') != null && prefs.get('country') != null) {
    location['city'] = prefs.get('city');
    location['country'] = prefs.get('country');
  } else {
    try {
      location = await getCountry();
      prefs.setString('country', location['country']);
      prefs.setString('city', location['city']);
      print("Get new location ${location['country']}");
    } catch (e) {
      throw Exception("time out");
    }
  }

  if (location['country'] != prefs.getString('country')) {
    prefs.setString('prayers', "");
    prefs.setString('country', location['country']);
    prefs.setString('city', location['city']);
  } else {
    prayerJs = prefs.getString('prayers');
  }

  var dateNow = DateTime.now();
  if (prefs.getString("prayers_month") != dateNow.month.toString()) {
    prayerJs = null;
  }

  List<Prayer> todayPrayer = [];
  if (prayerJs != null) {
    print("Get data Not for first time");
    DateTime now = DateTime.now();
    for (var element in (jsonDecode(prayerJs) as List<dynamic>)) {
      if (DateFormat("dd-MM-yyyy").parse(element["date"]).isSameDate(now)) {
        todayPrayer =
            (jsonDecode(element["prayers"]) as List<dynamic>).map((e) => Prayer.fromJson(e)).toList();
      }
    }
  } else {
    print("Get data for the first time ");
    var allDates = await getAllData();
    DateTime now = DateTime.now();
    prefs.setString('prayers', jsonEncode(allDates, toEncodable: (e) => (e as PrayerDate).toJson()));

    for (var element in allDates) {
      if (DateFormat("dd-MM-yyyy").parse(element.date).isSameDate(now)) {
        //Get the prayers of this day.
        todayPrayer = element.prayers;
      } else {
        log("Prayers of ${DateFormat("dd-MM-yyyy").parse(element.date)} are not exists");
      }
    }
  }
  getCountry().then((value) async {
    if (value['country'] != prefs.get('country')) {
      print("Get data for the first time CHANGE COUNTRY");



      await prefs.setString('country', value['country']);
      await prefs.setString('city', value['city']);

      var allDates = await getAllData();

      await prefs.setString('prayers', jsonEncode(allDates, toEncodable: (e) => (e as PrayerDate).toJson()));

      changeLocation();
    }
  });
  return todayPrayer;
}
