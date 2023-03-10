import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_planner/pages/edit_meal_page.dart';
import 'package:meal_planner/services/meal_plan.dart';
import 'package:meal_planner/services/settings.dart';
import 'package:meal_planner/shared/constants.dart';
import 'package:provider/provider.dart';

class MealsPage extends StatefulWidget {
  const MealsPage({super.key});

  @override
  State<MealsPage> createState() => _MealsPageState();
}

class _MealsPageState extends State<MealsPage> {
  late DateTime day;
  late DateTime today;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    day = DateTime(now.year, now.month, now.day);
    today = day;
  }

  Future<bool> _cacheMPD() async {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    if (settings.mpCachingNeeded) {
      await settings.getCurMealPlanData();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _cacheMPD(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        Widget ret = Container();

        if (snapshot.hasData) {
          ret = Consumer<YogaSettings>(
            builder: (context, settings, _) {
              String formatted = DateFormat('MMM dd, y').format(day);
              List<Widget> dayList = _dayList(day, settings.mealPlanData);
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // week header

                    Container(
                      color: (day == today)
                          ? Colors.red[100]
                          : Colors.lightBlue[100],
                      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (today.difference(day).inDays < 7 * numWeeks)
                                day = day.subtract(Duration(days: 7));
                              else
                                showToast(context,
                                    'Cannot go beyond $numWeeks weeks');
                              setState(() {});
                            },
                            icon: const Icon(Icons.arrow_back),
                          ),
                          Row(
                            children: [
                              Text(
                                'Week of ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              Text(
                                '$formatted',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              if (day.difference(today).inDays < 7 * numWeeks)
                                day = day.add(Duration(days: 7));
                              else
                                showToast(context,
                                    'Cannot go beyond $numWeeks weeks');
                              setState(() {});
                            },
                            icon: const Icon(Icons.arrow_forward),
                          ),
                        ],
                      ),
                    ),

                    // copy button

                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: _copyLastWeek,
                            child: Text('Copy from last week')),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: _clearWeek,
                            child: Text('Clear this week')),
                      ],
                    ),

                    // daily cards

                    Column(
                      children: dayList,
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              );
            },
          );
        } else {
          ret = Scaffold(
            appBar: AppBar(title: Text('Loading ...')),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 60),
                Container(
                  child: CircularProgressIndicator(),
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                ),
                Container(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Loading meal data ...'),
                  alignment: Alignment.center,
                )
              ],
            ),
          );
        }
        return ret;
      },
    );
  }

  void _copyLastWeek() async {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);

    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Are you sure?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
            'This will NOT overwrite the days below on which meal entries are present'),
        actions: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Yes')),
        ],
      ),
    );

    if (!confirm) return;

    int copied = 0, skipped = 0, srcNull = 0;

    for (int i = 0; i < 7; i++) {
      DateTime dstDay = day.add(Duration(days: i));
      DateTime srcDay = dstDay.subtract(Duration(days: 7));
      if (settings.mealPlanData[srcDay] != null) {
        if (settings.mealPlanData[dstDay] != null) {
          if (settings.mealPlanData[dstDay]!.empty()) {
            await settings.saveMealPlanData(
                dstDay, settings.mealPlanData[srcDay]!);
            copied++;
          } else
            skipped++;
        } else {
          await settings.saveMealPlanData(
              dstDay, settings.mealPlanData[srcDay]!);
          copied++;
        }
      } else
        srcNull++;
    }
    setState(() {});
    showMsg(context,
        'Copied $copied days. skipped $skipped days ($srcNull days empty in last week)!!');
  }

  void _clearWeek() async {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);

    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Are you sure?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
            'This will delete all meal entries for the entire current week'),
        actions: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Yes')),
        ],
      ),
    );

    if (!confirm) return;

    int deleted = 0;
    for (int i = 0; i < 7; i++) {
      DateTime dstDay = day.add(Duration(days: i));
      if (settings.mealPlanData[dstDay] != null) {
        await settings.delMealPlanData(dstDay);
        deleted++;
      }
    }

    setState(() {});
    showMsg(context, 'Deleted $deleted days!!');
  }

  List<Widget> _dayList(DateTime day, Map<DateTime, DayMeal> mealMap) {
    List<Widget> ret = [];

    for (var i = 0; i < 7; i++) {
      DateTime nday = day.add(Duration(days: i));
      ret.add(_dayTile(nday, mealMap[nday] ?? DayMeal('', '', '', {})));
    }
    return ret;
  }

  Widget _dayTile(DateTime date, DayMeal dayMeal) {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    DateFormat formatter = DateFormat('MMM dd, y (E)');
    String formatted = formatter.format(date);

    return Card(
      margin: const EdgeInsets.fromLTRB(10, 20, 10, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Column(
        children: [
          // date

          Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatted,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                (date == today)
                    ? Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(
                          '  TODAY  ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    : Container(),
                IconButton(
                    onPressed: () {
                      _editMeal(date, dayMeal);
                    },
                    icon: Icon(Icons.edit)),
              ],
            ),
          ),

          // breakfast snack

          (settings.getBsnack()
              ? Container(
                  margin: const EdgeInsets.fromLTRB(45, 10, 10, 0),
                  padding: const EdgeInsets.all(5),
                  color: Colors.lightBlue[100],
                  child: Row(
                    children: [
                      Text(
                        'Snack: ${settings.meals[dayMeal.other[BSNACK] ?? '']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              : Container()),

          // breakfast

          SizedBox(height: 10),
          Row(
            children: [
              SizedBox(width: 10),
              Icon(Icons.free_breakfast),
              Flexible(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.all(5),
                  color: Colors.lightGreen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                          Text(
                            '${settings.meals[dayMeal.breakfast]}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ] +
                        (settings.getBside()
                            ? <Widget>[
                                SizedBox(height: 5),
                                Text(
                                  '${settings.meals[dayMeal.other[BSIDE] ?? '']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ]
                            : []),
                  ),
                ),
              ),
            ],
          ),

          // lunch snack

          (settings.getLsnack()
              ? Container(
                  margin: const EdgeInsets.fromLTRB(45, 10, 10, 0),
                  padding: const EdgeInsets.all(5),
                  color: Colors.lightBlue[100],
                  child: Row(
                    children: [
                      Text(
                        'Snack: ${settings.meals[dayMeal.other[LSNACK] ?? '']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              : Container()),

          // lunch

          SizedBox(height: 10),
          Row(
            children: [
              SizedBox(width: 10),
              Icon(Icons.lunch_dining),
              Flexible(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.all(5),
                  color: Colors.yellow,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                          Text(
                            '${settings.meals[dayMeal.lunch]}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ] +
                        (settings.getLside()
                            ? <Widget>[
                                SizedBox(height: 5),
                                Text(
                                  '${settings.meals[dayMeal.other[LSIDE] ?? '']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ]
                            : []),
                  ),
                ),
              ),
            ],
          ),

          // dinner snack

          (settings.getDsnack()
              ? Container(
                  margin: const EdgeInsets.fromLTRB(45, 10, 10, 0),
                  padding: const EdgeInsets.all(5),
                  color: Colors.lightBlue[100],
                  child: Row(
                    children: [
                      Text(
                        'Snack: ${settings.meals[dayMeal.other[DSNACK] ?? '']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              : Container()),

          // dinner

          SizedBox(height: 10),
          Row(
            children: [
              SizedBox(width: 10),
              Icon(Icons.dinner_dining),
              Flexible(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.all(5),
                  color: Colors.orange,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                          Text(
                            '${settings.meals[dayMeal.dinner]}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ] +
                        (settings.getDside()
                            ? <Widget>[
                                SizedBox(height: 5),
                                Text(
                                  '${settings.meals[dayMeal.other[DSIDE] ?? '']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ]
                            : []),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }

  void _editMeal(DateTime date, DayMeal dayMeal) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return EditMeal(
          date: date,
          dayMeal: dayMeal,
        );
      }),
    ).then((value) {
      setState(() {});
    });
  }
}
