import 'dart:convert';
import 'package:flutter/material.dart';

final Map<String,IconData> measureType = {
  "hr":     Icons.favorite,
  "bp":     Icons.mic_external_on_rounded,
  "spo2" :  Icons.bloodtype,
  "stress": Icons.eco_sharp,
  "hrv":    Icons.heart_broken_sharp,
  "temp":   Icons.thermostat,
  "bs":     Icons.bloodtype_outlined,
};

final Map<String,String> measureName = {
  "hr":     "Heart Rate",
  "bp":     "Blood Pressure",
  "spo2" :  "Oxygen saturation",
  "stress": "Stress",
  "hrv":    "HRV",
  "temp":   "Temperature",
  "bs":     "Blood Sugar Level",
};

void showToast(BuildContext context, String text) {
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      content: Text(text, style: const TextStyle(
        fontSize: 12, fontStyle: FontStyle.italic/*, color: Colors.white,*/)),
      action: SnackBarAction(
          label: 'CLOSE', onPressed: scaffold.hideCurrentSnackBar),
      persist: false,
    ),
  );
}

// String composeColorJsonString(Color color) {
//   List<int> list = colors2Rgb(color);
//   final ColorModel colorModel = ColorModel(r: list[0], g: list[1], b: list[2]);
//   String jsonString = jsonEncode(colorModel.toJson());
//   print ('composeColorJsonString->$jsonString');
//   return jsonString;
// }

// String detectMessageType(String jsonString) {
//   String result = "";
//   final map = jsonDecode(jsonString) as Map<String, dynamic>;
//   if (map.containsKey('cmd')) {
//     result = 'cmd';
//   }
//   else
//   if (map.containsKey('color'))  {
//     result = 'color';
//   }
//   else
//   if (map.containsKey('Location'))  {
//     result = 'weather';
//   }
//   else
//   if (map.containsKey('modulus') && map.containsKey('exponent'))  {
//     result = 'publicKey';
//   }
//   else
//   if (map.containsKey('encrypted_key'))  {
//     result = 'packet';
//   }
//   else
//   if (map.containsKey('pong'))  {
//     result = 'pong';
//   }
//   else
//   if (map.containsKey('discovery'))  {
//     result = 'discovery';
//   }
//   else
//   if (map.containsKey('connection'))  {
//     result = 'connection';
//   }
//   else
//   if (map.containsKey('measure'))  {
//     result = 'measure';
//   }
//   else
//   if (map.containsKey('disconnect'))  {
//     result = 'disconnect';
//   }
//   return result;
// }

// dynamic getValue(dynamic value) {
//   if (value == null) {
//     return value;
//   }
//   if (value is String) {
//     if (value == 'Measure error'
//     ||  value == 'Missing data'
//     ||  value == 'Lost BLE connection'
//     ||  value == 'Unknown measure error') {
//       return "⚠";
//     }
//   }
//   return value;
// }

bool isMeasureError(String? value) {
  bool result = false;
  if (value == null) {
    return result;
  }
  if (    value == 'Measure error'
      ||  value == 'Missing data'
      ||  value == 'Lost BLE connection'
      ||  value == 'Unknown measure error') {
    result = true;
  }
  return result;
}

// List<int> colors2Rgb(Color color) {
//   return [color.red, color.green, color.blue];
// }

// RGB to Colors
// Color rgb2Colors(int r, int g, int b) {
//   return Color.fromRGBO(r, g, b, 1.0);
// }

String discoveryTime(String? discoveryTime) {
  if (discoveryTime == null || discoveryTime.isEmpty) {
    return '-';
  }
  return  discoveryTime.toString();
}

IconData? getIcon (String measure) {
  if (!measureType.containsKey(measure)) {
    return Icons.hourglass_empty;
  }
  return measureType[measure];
}

bool getBlinking(String state) {
  bool result = false;
  if (state == "measuring-start") {
    result = true;
  }
  return result;
}

String? getName(String measure) {
  if (!measureName.containsKey(measure)) {
    return "";
  }
  return measureName[measure];
}

