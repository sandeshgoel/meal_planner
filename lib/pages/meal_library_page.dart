import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    controller1 = TextEditingController();
    controller2 = TextEditingController();
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
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
        children: settings.meals.keys
            .map((k) => Text('$k: ${settings.meals[k]}'))
            .toList(),
      ),
    );
  }

  void _addMeal() async {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);

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
          ],
        ),
        actions: [
          TextButton(
              onPressed: () {
                String label = controller1.text;
                String name = controller2.text;
                controller1.clear();
                controller2.clear();
                Navigator.of(context).pop([label, name]);
              },
              child: Text('Submit'))
        ],
      ),
    );

    String label = name[0].trim();
    String display = name[1].trim();

    if (label.isEmpty) {
      showMsg(context, 'Label can\'t be empty, try again!!');
    } else if (display.isEmpty) {
      showMsg(context, 'Name can\'t be empty, try again!!');
    } else if (label.contains(' ')) {
      showMsg(context, 'Label can\'t contain space, try again!!');
    } else if (settings.meals.keys.any((x) => x == label)) {
      showMsg(context, 'Meal \'$label\' already exists!!');
    } else {
      Meal m = Meal(label: label, display_name: display);
      settings.meals[label] = display;
      DBService(email: settings.getUser().email).addMeal(m);
      showMsg(context, 'Added Meal $name');
    }
    setState(() {});
  }
}
