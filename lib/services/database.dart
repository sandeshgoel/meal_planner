import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meal_planner/services/settings.dart';

class DBService {
  final String email;
  static Map<String, dynamic> _lastCfg = {};

  DBService({required this.email});

// -------------------------------------------------

  final CollectionReference cfgCollection =
      FirebaseFirestore.instance.collection('configs');

  Future updateUserData(YogaSettings cfg) async {
    YogaSettings lastCfg = YogaSettings();
    lastCfg.settingsFromJson(_lastCfg);

    if (cfg.equals(lastCfg)) {
      print('updateUserData: config unchanged, skipping write to DB');
    } else {
      print('updateUserData: config changed, writing to DB ...');
      Map<String, dynamic> jval = cfg.settingsToJson();
      _lastCfg = jsonDecode(jsonEncode(jval)); // make a copy
      await cfgCollection.doc(email).set(jval);
    }
  }

  Future getUserData() async {
    return await cfgCollection.doc(email).get();
  }

// -------------------------------------------------

  final CollectionReference mpCollection =
      FirebaseFirestore.instance.collection('mealplans');

  Future<String> addMealPlan(Map<String, dynamic> mp) async {
    String docId = '';

    print('Writing to DB mealplan ...');
    await mpCollection.add(mp).then((documentSnapshot) {
      docId = documentSnapshot.id;
      print("Added Data with ID: ${docId}");
    });
    return docId;
  }

  Future getMealPlan(String docId) async {
    print('Getting from meal plan, doc id $docId ...');
    return await mpCollection.doc(docId).get();
  }

// -------------------------------------------------

}
