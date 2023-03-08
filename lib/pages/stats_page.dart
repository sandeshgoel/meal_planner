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
  int pastDays = numWeeks * 7; // includes today
  int futureDays = (numWeeks + 1) * 7;

  int pastMeals = 0;
  int futureMeals = 0;

  Map<String, int> mealCount = {};
  List<MealCounter> mlist = [];

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
    for (DateTime date in settings.mealPlanData.keys) {
      if (date.isBefore(DateTime.now())) {
        DayMeal m = settings.mealPlanData[date]!;
        stats.incrementMealCount(m.breakfast);
        stats.incrementMealCount(m.lunch);
        stats.incrementMealCount(m.dinner);
        stats.pastMeals += 1;
      } else
        stats.futureMeals += 1;
    }

    stats.mlist = [];
    for (String l in stats.mealCount.keys) {
      stats.mlist.add(MealCounter(l, stats.mealCount[l] ?? 0));
    }
    stats.mlist.sort(((a, b) => b.count.compareTo(a.count)));
    stats.mlist = stats.mlist.sublist(0, min(stats.mlist.length, 4));
  }

  @override
  Widget build(BuildContext context) {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);

    _computeStats(settings);

    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(10),
            child: Column(
              children: [
                    Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Text(
                          'Past',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text(
                          '${stats.pastMeals} / ${stats.pastDays} days have meals'),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text(
                        'Favorite meals',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ] +
                  stats.mlist
                      .map((e) => Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 80, vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(settings.meals[e.meal]!),
                              Text(e.count.toString())
                            ],
                          )))
                      .toList() +
                  [
                    Container(height: 20),
                  ],
            ),
          ),
          Card(
            margin: EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Text(
                      'Future',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text(
                      '${stats.futureMeals} / ${stats.futureDays} days have meals'),
                ),
                Container(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
