import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
      await log({'type': 'configs', 'sub': 'write', 'value': jval});
    }
  }

  Future getUserData() async {
    await log({'type': 'configs', 'sub': 'read'});
    return await cfgCollection.doc(email).get();
  }

  Future<List<YogaSettings>> getUsers() async {
    print('Getting all users ...');
    QuerySnapshot queryRef = await cfgCollection.get();
    print('Fetched all users: ${queryRef.docs.length} docs ...');
    await log(
        {'type': 'configs', 'sub': 'read_all', 'value': queryRef.docs.length});
    return queryRef.docs
        .map<YogaSettings>(
            (doc) => YogaSettings.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<DocumentSnapshot> getOtherUser(String otherEmail) async {
    DocumentSnapshot doc = await cfgCollection.doc(otherEmail).get();
    await log({'type': 'configs', 'sub': 'read_other', 'value': otherEmail});
    return doc;
  }

  Future updateOtherUserData(String otherEmail, YogaSettings cfg) async {
    Map<String, dynamic> jval = cfg.settingsToJson();
    _lastCfg = jsonDecode(jsonEncode(jval)); // make a copy
    await cfgCollection.doc(otherEmail).set(jval);
    await log({'type': 'configs', 'sub': 'write_other', 'value': otherEmail});
    print('Updated profile for $otherEmail');
  }

// -------------------------------------------------

  final CollectionReference hideCollection =
      FirebaseFirestore.instance.collection('hiddenMeals');

  Future updateHiddenMeals(List<String> meals) async {
    Map<String, dynamic> jval = {'meals': meals};

    await cfgCollection.doc(email).set(jval);
    await log({'type': 'hiddenMeals', 'sub': 'write', 'value': jval});
  }

  Future getHiddenMeals() async {
    await log({'type': 'hiddenMeals', 'sub': 'read'});
    return await hideCollection.doc(email).get();
  }

// -------------------------------------------------

  final CollectionReference mpCollection =
      FirebaseFirestore.instance.collection('mealplans');

  Future addMealPlan(String mpid, Map<String, dynamic> mp) async {
    await mpCollection.doc(mpid).set(mp);
    print('Written to DB mealplan $mpid...');
    await log({'type': 'mealplans', 'sub': 'write', 'value': mpid});
  }

  Future updateMealPlan(Map<String, dynamic> mp, String mpid) async {
    await mpCollection.doc(mpid).set(mp);
    print("Updated meal plan with ID: $mpid");
    await log({'type': 'mealplans', 'sub': 'update', 'value': mpid});
  }

  Future getMealPlan(String docId) async {
    print('Getting from meal plan, doc id $docId ...');
    await log({'type': 'mealplans', 'sub': 'read', 'value': docId});
    return await mpCollection.doc(docId).get();
  }

// -------------------------------------------------

  final CollectionReference mpDataCollection =
      FirebaseFirestore.instance.collection('mealplanData');

  Future addMealPlanData(Map<String, dynamic> mpd) async {
    String docid = mpd['mpid'] + '_' + DateFormat('yyMMdd').format(mpd['date']);
    await log({'type': 'mealplanData', 'sub': 'write', 'value': docid});
    await mpDataCollection.doc(docid).set(mpd);
  }

  Future delMealPlanData(String mpid, DateTime date) async {
    String docid = mpid + '_' + DateFormat('yyMMdd').format(date);
    print('Deleting from mealplanData, $docid ...');
    await mpDataCollection.doc(docid).delete();
    await log({'type': 'mealplanData', 'sub': 'delete', 'value': docid});
  }

  Future<QuerySnapshot> getMealPlanData(String mpid, DateTime date) async {
    String docid = mpid + '_' + DateFormat('yyMMdd').format(date);
    print('Getting from mealplanData, mpid $mpid $date ...');
    await log({'type': 'mealplanData', 'sub': 'read', 'value': docid});
    return await mpDataCollection
        .where('mpid', isEqualTo: mpid)
        .where('date', isEqualTo: date)
        .get();
  }

  Future<QuerySnapshot> getMealPlanDataDuration(
      String mpid, DateTime startDate, int numDays) async {
    DateTime endDate = startDate.add(Duration(days: numDays));
    print('Getting from mealplanData, mpid $mpid $startDate $endDate...');
    String docid = mpid + '_' + DateFormat('yyMMdd').format(startDate);
    await log({
      'type': 'mealplanData',
      'sub': 'read_range',
      'value': docid,
      'days': numDays
    });

    return await mpDataCollection
        .where('mpid', isEqualTo: mpid)
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThan: endDate)
        .get();
  }

// -------------------------------------------------

  final CollectionReference mealsCollection =
      FirebaseFirestore.instance.collection('meallib');

  Future addMeal(Map<String, dynamic> m, String label) async {
    print('Writing to DB meallib $m ...');
    await mealsCollection.doc(label).set(m, SetOptions(merge: true));
    await log({'type': 'meallib', 'sub': 'write', 'value': m.toString()});
  }

  Future<QuerySnapshot> getMeals() async {
    print('Getting from meals library ...');
    QuerySnapshot queryRef = await mealsCollection.get();
    await log(
        {'type': 'meallib', 'sub': 'read_all', 'value': queryRef.docs.length});
    return queryRef;
  }

// -------------------------------------------------
  final CollectionReference logCollection =
      FirebaseFirestore.instance.collection('logs');

  Future log(Map<String, dynamic> msg) async {
    msg['user'] = email;
    msg['time'] = DateTime.now();
    await logCollection.add(msg);
  }

// -------------------------------------------------
}
