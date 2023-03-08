import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_planner/services/meal_plan.dart';
import 'package:meal_planner/services/popup_submenu.dart';
import 'package:meal_planner/services/settings.dart';
import 'package:provider/provider.dart';

class EditMeal extends StatefulWidget {
  final DateTime date;
  final DayMeal dayMeal;
  const EditMeal({required this.date, required this.dayMeal, super.key});

  @override
  State<EditMeal> createState() => _EditMealState();
}

class _EditMealState extends State<EditMeal> {
  late DayMeal _lastSaved;
  @override
  void initState() {
    super.initState();
    _lastSaved = widget.dayMeal.copy();
    print('_init called');
  }

  @override
  Widget build(BuildContext context) {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    DateFormat formatter = DateFormat('MMM dd, y (E)');
    String formatted = formatter.format(widget.date);
    print('cur: ${widget.dayMeal.toString()}');
    print('last: ${_lastSaved.toString()}');

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Meals'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // heading

            Container(
              width: double.infinity,
              color: Colors.lightBlue,
              padding: EdgeInsets.all(10),
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 20),
              child: Center(
                child: Text(
                  'Edit meals for $formatted',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),

            // breakfast
            (settings.getBsnack() ? _editMealTile(BSNACK) : Container()),
            _editMealTile(BREAKFAST),
            (settings.getBside() ? _editMealTile(BSIDE) : Container()),
            Divider(),
            (settings.getLsnack() ? _editMealTile(LSNACK) : Container()),
            _editMealTile(LUNCH),
            (settings.getLside() ? _editMealTile(LSIDE) : Container()),
            Divider(),
            (settings.getDsnack() ? _editMealTile(DSNACK) : Container()),
            _editMealTile(DINNER),
            (settings.getDside() ? _editMealTile(DSIDE) : Container()),

            // Save

            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel')),
                  ElevatedButton(
                      onPressed: (_lastSaved.equalTo(widget.dayMeal))
                          ? null
                          : () async {
                              await settings.saveMealPlanData(
                                  widget.date, widget.dayMeal);
                              _lastSaved = widget.dayMeal.copy();
                              print('Save pressed');
                              setState(() {});
                              Navigator.pop(context);
                            },
                      child: Text('Save')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _displayName(String label) {
    switch (label) {
      case BREAKFAST:
        return 'Breakfast';
      case LUNCH:
        return 'Lunch';
      case DINNER:
        return 'Dinner';
      case BSNACK:
        return 'Snack';
      case BSIDE:
        return 'Breakfast Side';
      case LSNACK:
        return 'Snack';
      case LSIDE:
        return 'Lunch Side';
      case DSNACK:
        return 'Snack';
      case DSIDE:
        return 'Dinner Side';
      default:
        return '';
    }
  }

  String _displayMeal(String label) {
    switch (label) {
      case BREAKFAST:
        return widget.dayMeal.breakfast;
      case LUNCH:
        return widget.dayMeal.lunch;
      case DINNER:
        return widget.dayMeal.dinner;
      default:
        return widget.dayMeal.other[label] ?? '';
    }
  }

  void _updateMeal(String label, String value) {
    switch (label) {
      case BREAKFAST:
        widget.dayMeal.breakfast = value;
        break;
      case LUNCH:
        widget.dayMeal.lunch = value;
        break;
      case DINNER:
        widget.dayMeal.dinner = value;
        break;
      default:
        widget.dayMeal.other[label] = value;
        break;
    }
  }

  Widget _editMealTile(String label) {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);

    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _displayName(label),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(settings.meals[_displayMeal(label)]!),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select:'),
                PopupMenuButton<String>(
                  icon: Icon(Icons.arrow_drop_down),
                  tooltip: 'Categories',
                  onSelected: (value) {
                    //Do something with selected parent value
                    print('$value parent selected');
                  },
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuEntry<String>>[
                      PopupSubMenuItem<String>(
                        title: displayCategory(MealCategory.dal),
                        items: settings.listMeals(MealCategory.dal),
                        display_function: (val) => settings.meals[val]!,
                        onSelected: (value) {
                          //Do something with selected child value
                          print('$value selected');
                          setState(() {
                            _updateMeal(label, value);
                          });
                        },
                      ),
                      PopupSubMenuItem<String>(
                        title: displayCategory(MealCategory.snack),
                        items: settings.listMeals(MealCategory.snack),
                        display_function: (val) => settings.meals[val]!,
                        onSelected: (value) {
                          //Do something with selected child value
                          print('$value selected');
                          setState(() {
                            _updateMeal(label, value);
                          });
                        },
                      ),
                      PopupSubMenuItem<String>(
                        title: displayCategory(MealCategory.veg),
                        items: settings.listMeals(MealCategory.veg),
                        display_function: (val) => settings.meals[val]!,
                        onSelected: (value) {
                          //Do something with selected child value
                          print('$value selected');
                          setState(() {
                            _updateMeal(label, value);
                          });
                        },
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
