import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meal_planner/services/meal_plan.dart';
import 'package:meal_planner/services/settings.dart';
import 'package:meal_planner/shared/constants.dart';
import 'package:provider/provider.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class Stats {
  int favCount = 6;
  int ignoreDef = 7;
  int pastDays = numWeeks * 7; // includes today
  int futureDays = (numWeeks + 1) * 7;

  int pastMeals = 0;
  int futureMeals = 0;

  Map<String, int> mealCount = {};
  List<MealCounter> mlist = [];
  List<String> ignoredSorted = [];
  Set<String> ignoredMeals = {};
  Set<String> unignoredMeals = {};
  Map<String, int> lastCooked = {};

  Set<String> allMeals = {};
  Set<String> missingMeals = {};

  void incrementMealCount(String label) {
    mealCount[label] = (mealCount[label] ?? 0) + 1;
  }
}

class MealCounter {
  String meal;
  int count;

  MealCounter(this.meal, this.count);
}

class _StatsPageState extends State<StatsPage> {
  Stats stats = Stats();

  void _computeStats(YogaSettings settings) {
    stats.pastMeals = stats.futureMeals = 0;
    stats.mlist = [];
    stats.mealCount = {};
    stats.ignoredMeals = {};
    stats.unignoredMeals = {};
    stats.lastCooked = {};

    stats.allMeals = {};
    stats.missingMeals = {};

    for (DateTime date in settings.mealPlanData.keys) {
      if (date.isBefore(DateTime.now())) {
        DayMeal m = settings.mealPlanData[date]!;
        List<String> mealList = [m.breakfast, m.dinner, m.lunch];
        for (String meal in m.other.values) mealList.add(meal);

        for (String meal in mealList) {
          stats.incrementMealCount(meal);
        }
        stats.pastMeals += 1;

        int days = DateTime.now().difference(date).inDays;

        if (date.isBefore(
            DateTime.now().subtract(Duration(days: stats.ignoreDef)))) {
          stats.ignoredMeals.addAll(mealList.toSet());
          for (String meal in mealList.toSet()) {
            if ((stats.lastCooked[meal] ?? stats.pastDays) > days)
              stats.lastCooked[meal] = days;
          }
        } else {
          stats.unignoredMeals.addAll(mealList.toSet());
        }
        stats.allMeals.addAll(mealList.toSet());
      } else
        stats.futureMeals += 1;
    }

    //print('${stats.ignoredMeals}, ${stats.unignoredMeals}');
    stats.ignoredMeals = stats.ignoredMeals.difference(stats.unignoredMeals);
    print(stats.ignoredMeals);
    stats.ignoredSorted = stats.ignoredMeals.toList();
    stats.ignoredSorted
        .sort((a, b) => stats.lastCooked[b]!.compareTo(stats.lastCooked[a]!));

    stats.missingMeals = settings.meals.keys.toSet().difference(stats.allMeals);

    for (String l in stats.mealCount.keys) {
      stats.mlist.add(MealCounter(l, stats.mealCount[l] ?? 0));
    }
    stats.mlist.sort(((a, b) => b.count.compareTo(a.count)));
    stats.mlist =
        stats.mlist.sublist(0, min(stats.mlist.length, stats.favCount));
  }

  @override
  Widget build(BuildContext context) {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);

    _computeStats(settings);

    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.lime],
                end: Alignment.topLeft,
                begin: Alignment.bottomRight,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                // Past card

                Card(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    children: [
                          Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: Text(
                                'Past',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Text(
                                '${stats.pastMeals} / ${stats.pastDays} days have meals'),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Text(
                              'Most Popular Meals',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ] +
                        stats.mlist
                            .map((e) => Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 80, vertical: 2),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(settings.meals[e.meal]!),
                                    Text(e.count.toString())
                                  ],
                                )))
                            .toList() +
                        [
                          Container(height: 10),
                        ],
                  ),
                ),

                // Ignored Meals

                Card(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Column(
                    children: [
                          Container(height: 10),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Text(
                              'Meals not cooked in last ${stats.ignoreDef} days',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(height: 10),
                        ] +
                        _listAllMeals(settings) +
                        [
                          Container(height: 20),
                        ],
                  ),
                ),

                // Missing Meals

                Card(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Column(
                    children: [
                          Container(height: 10),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Text(
                              'Meals missing in last ${numWeeks * 7} days',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(height: 10),
                        ] +
                        _listAllMissingMeals(settings) +
                        [
                          Container(height: 20),
                        ],
                  ),
                ),

                // Future card

                Card(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Column(
                    children: [
                      Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Text(
                            'Future',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text(
                            '${stats.futureMeals} / ${stats.futureDays} days have meals'),
                      ),
                      Container(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Container> _listAllMeals(YogaSettings settings) {
    List<Container> ret = [];

    for (MealCategory cat in MealCategory.values) {
      ret = ret + _listMeals(settings, cat);
    }
    return ret;
  }

  List<Container> _listMeals(YogaSettings settings, MealCategory cat) {
    return [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              displayCategory(cat),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(height: 10),
        ] +
        stats.ignoredSorted
            .map(
              (e) => (settings.mealsCategory[e] == cat)
                  ? Container(
                      margin: EdgeInsets.symmetric(horizontal: 80, vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(settings.meals[e]!),
                          Text('${stats.lastCooked[e]} days ago')
                        ],
                      ),
                    )
                  : Container(),
            )
            .toList();
  }

  List<Container> _listAllMissingMeals(YogaSettings settings) {
    List<Container> ret = [];

    for (MealCategory cat in MealCategory.values) {
      ret = ret + _listMissingMeals(settings, cat);
    }
    return ret;
  }

  List<Container> _listMissingMeals(YogaSettings settings, MealCategory cat) {
    return [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              displayCategory(cat),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(height: 10),
        ] +
        stats.missingMeals
            .map(
              (e) => (settings.mealsCategory[e] == cat)
                  ? Container(
                      margin: EdgeInsets.symmetric(horizontal: 80, vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(settings.meals[e]!),
                          InkWell(
                            onTap: () =>
                                showMsg(context, 'Not implemented yet'),
                            child: Text(
                              'Hide for me',
                              style: TextStyle(color: Colors.blue),
                            ),
                          )
                        ],
                      ),
                    )
                  : Container(),
            )
            .toList();
  }
}
