import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/pages/edit_meal_plan_page.dart';
import 'package:meal_planner/services/meal_plan.dart';
import 'package:provider/provider.dart';

import 'package:meal_planner/services/settings.dart';
import 'package:meal_planner/shared/constants.dart';

class ManagePage extends StatefulWidget {
  const ManagePage({Key? key}) : super(key: key);

  @override
  _ManagePageState createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<YogaSettings>(builder: (context, settings, _) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Manage Meal Plans'),
        ),
        body: _listMealPlans(settings),
        floatingActionButton: FloatingActionButton(
          // isExtended: true,
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
          onPressed: _addMealPlan,
        ),
      );
    });
  }

  void _addMealPlan() async {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);

    String name = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Meal Plan Name',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration:
              InputDecoration(hintText: 'Enter the name of meal plan ...'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: Text('Submit'))
        ],
      ),
    );

    if (settings.mealPlans.any((x) => x.name == name)) {
      showMsg(context, 'Meal Plan \'$name\' already exists!!');
    } else {
      settings.addMealPlan(name);
      showMsg(context, 'Added Meal Plan');
    }
    setState(() {});
  }

  Widget _listMealPlans(YogaSettings settings) {
    List<Widget> rlist = [];
    List<MealPlanRole> mprs = settings.getMprs();

    print(mprs);
    for (int i = 0; i < mprs.length; i++)
      rlist.add(_mealPlanTile(settings, mprs[i], settings.mealPlans[i], i));

    return SingleChildScrollView(child: Column(children: rlist));
  }

  Widget _mealPlanTile(
      YogaSettings settings, MealPlanRole mpr, MealPlan r, int index) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Row(
        children: [
          Expanded(
            flex: 85,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: boxDeco,
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //Text(annotation, style: starStyle),
                      Text(
                        r.name.length > 22
                            ? '${r.name.substring(0, 20)}...'
                            : '${r.name}',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Role:${describeEnum(mpr.mpRole)}, Creator:${r.creator}',
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed:
                            (settings.getCurMpIndex() == index) ? null : () {},
                        child: Text('Select'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _editMealPlan(context, index);
                        },
                        child: Text('Manage'),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              )),
            ),
          ),
        ],
      ),
    );
  }

  void _editMealPlan(context, index) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return EditMealPlan(index: index);
      }),
    ).then((value) {
      setState(() {});
    });
  }
}
