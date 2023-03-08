import 'package:flutter/material.dart';
import 'package:meal_planner/pages/edit_meal_lib_page.dart';
import 'package:meal_planner/services/database.dart';
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

  @override
  void initState() {
    super.initState();
    controller1 = TextEditingController();
    controller2 = TextEditingController();
    controller3 = TextEditingController();
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
          onPressed: _addMeal,
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
                          'Touch the row to edit display name for that meal',
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
                                    onTap: () => _editMeal(k),
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

  void _editMeal(String label) {
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

  void _addMeal() async {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    MealCategory category = MealCategory.snack;

    List<String> name = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Meal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          children: [
            TextField(
              controller: controller1,
              autofocus: true,
              decoration: InputDecoration(hintText: 'Enter label'),
            ),
            TextField(
              controller: controller2,
              decoration: InputDecoration(hintText: 'Enter display name'),
            ),
            DropdownButton<MealCategory>(
              value: category,
              items: MealCategory.values
                  .map((k) => DropdownMenuItem<MealCategory>(
                      value: k,
                      child: Text(
                        displayCategory(k),
                        style: TextStyle(fontSize: 12),
                      )))
                  .toList(),
              onChanged: (MealCategory? newValue) {
                setState(() {
                  category = newValue!;
                });
              },
            ),
          ],
        ),
        actions: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                controller1.clear();
                controller2.clear();
                Navigator.of(context).pop(['', '']);
              },
              child: Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                String label = controller1.text;
                String name = controller2.text;
                controller1.clear();
                controller2.clear();
                Navigator.of(context).pop([label, name]);
              },
              child: Text('Submit')),
        ],
      ),
    );

    String label = name[0].trim();
    String display = name[1].trim().toTitleCase();

    if (label.isEmpty & display.isEmpty) return;

    if (label.isEmpty) {
      showMsg(context, 'Label can\'t be empty, try again!!');
    } else if (display.isEmpty) {
      showMsg(context, 'Name can\'t be empty, try again!!');
    } else if (label.contains(' ')) {
      showMsg(context, 'Label can\'t contain space, try again!!');
    } else if (settings.meals.keys.any((x) => x == label)) {
      showMsg(context, 'Meal label \'$label\' already exists!!');
    } else if (settings.meals.values.any((x) => x == display)) {
      showMsg(context, 'Meal name \'$display\' already exists!!');
    } else {
      Meal m = Meal(label: label, display_name: display, category: category);
      settings.meals[label] = display;
      settings.mealsCategory[label] = category;
      await DBService(email: settings.getUser().email)
          .addMeal(m.toJson(), label);
      showToast(context, 'Added Meal $label,$display');
    }
    setState(() {});
  }
}
