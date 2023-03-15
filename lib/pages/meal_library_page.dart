import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/pages/add_meal_lib_page.dart';
import 'package:meal_planner/pages/edit_meal_lib_page.dart';
import 'package:meal_planner/services/meal_plan.dart';
import 'package:meal_planner/services/settings.dart';
import 'package:meal_planner/shared/constants.dart';
import 'package:provider/provider.dart';

class MealLibrary extends StatefulWidget {
  const MealLibrary({super.key});

  @override
  State<MealLibrary> createState() => _MealLibraryState();
}

class _MealLibraryState extends State<MealLibrary> {
  late TextEditingController controller1;
  late TextEditingController controller2;
  late TextEditingController controller3;
  late MealCategory category;

  @override
  void initState() {
    super.initState();
    controller1 = TextEditingController();
    controller2 = TextEditingController();
    controller3 = TextEditingController();
    category = MealCategory.snack;
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<YogaSettings>(builder: (context, settings, _) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Meal Library'),
        ),
        body: _listMeals(settings),
        floatingActionButton: FloatingActionButton(
          // isExtended: true,
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
          onPressed: () => _addMeal(settings),
        ),
      );
    });
  }

  Widget _listMeals(YogaSettings settings) {
    return SingleChildScrollView(
      child: Column(
          children: <Widget>[
                Container(
                  color: Colors.lightBlue,
                  margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Label',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Display Name',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ] +
              MealCategory.values
                  .map((e) => _listMealsCategory(settings, e))
                  .toList() +
              [
                Container(
                  margin: EdgeInsets.all(5),
                  child: Card(
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          'Touch the row to edit display name for that meal (only superusers)',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 80),
              ]),
    );
  }

  Widget _listMealsCategory(YogaSettings settings, MealCategory category) {
    return Container(
      margin: EdgeInsets.all(5),
      child: Card(
        child: Column(
            children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      'Category: ${displayCategory(category)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ] +
                settings.meals.keys
                    .map(
                      (k) => (settings.mealsCategory[k] == category)
                          ? Container(
                              //color: Colors.lightBlue[100],
                              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              padding: EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 5),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () => _editMeal(settings, k),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(k),
                                        Text('${settings.meals[k]}'),
                                      ],
                                    ),
                                  ),
                                  Divider(),
                                ],
                              ),
                            )
                          : Container(),
                    )
                    .toList()),
      ),
    );
  }

  void _editMeal(YogaSettings settings, String label) {
    if (settings.getSuperUser()) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) {
          return EditMealLib(
            label: label,
          );
        }),
      ).then((value) {
        setState(() {});
      });
    }
  }

  void _addMeal(YogaSettings settings) async {
    if (settings.getSuperUser()) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) {
          return AddMealLib();
        }),
      ).then((value) {
        setState(() {});
      });
    } else {
      showMsg(context, 'Request the owner of the app for this functionality');
    }
  }
}
