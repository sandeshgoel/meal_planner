import 'package:flutter/material.dart';
import 'package:meal_planner/services/database.dart';
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
    String email = settings.getUser().email;

    MealPlan mp =
        MealPlan(name: 'Goels Meal Plan', creator: email, admins: [email]);
    String mpId = await DBService(email: email).addMealPlan(mp.toJson());
    MealPlanRole mprole = MealPlanRole(mpId, MpRole.admin);
    settings.addMpRole(mprole, mp);
    showMsg(context, 'Added Meal Plan');
  }

  Widget _mealPlanTile(YogaSettings settings, MealPlanRole mpr, MealPlan r) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Row(
        children: [
          Expanded(
            flex: 85,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5),
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
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text(
                    '${mpr.mpRole}(creator:${r.creator})',
                    style: TextStyle(fontSize: 10),
                  )
                ],
              )),
            ),
          ),
          Expanded(flex: 3, child: Container()),
          Expanded(
            flex: 12,
            child: CircleAvatar(
              //radius: 25,
              child: IconButton(
                onPressed: () {
                  //_editRoutine(context, r.name);
                },
                icon: Icon(Icons.edit, size: 20),
                tooltip: 'Edit config',
              ),
              backgroundColor: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _listMealPlans(YogaSettings settings) {
    List<Widget> rlist = [];
    List<MealPlanRole> mprs = settings.getMprs();

    print(mprs);
    for (int i = 0; i < mprs.length; i++)
      rlist.add(_mealPlanTile(settings, mprs[i], settings.mealPlans[i]));

    return SingleChildScrollView(child: Column(children: rlist));
  }

// ----------------------------------------------------
/*
  Widget _createRoutineTile(String name) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _addRoutine(context, name);
      },
      child: Container(
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(10),
          width: double.infinity,
          decoration: boxDeco,
          child: Text(name, style: TextStyle(fontSize: 12))),
    );
  }

  void _showRoutinePicker() {
    var settings = Provider.of<YogaSettings>(context, listen: false);

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: Column(
                  children: [
                        _createRoutineTile('Custom ...'),
                        SizedBox(height: 10)
                      ] +
                      settings
                          .getRoutineLibNotAdded()
                          .map((e) => _createRoutineTile(e.name))
                          .toList()),
              title: Text('Add routine'),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'))
              ],
            ),
        barrierDismissible: false);
  }

  void _addRoutine(context, String cfgName) {
    var settings = Provider.of<YogaSettings>(context, listen: false);
    int index = settings.findRoutineIndex(cfgName);

    if (index != -1) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('Already present'),
                content: Text(
                    'The routine $cfgName is already present. Delete it first to add it again.'),
                actions: [
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'))
                ],
              ),
          barrierDismissible: false);
      return;
    } else if (cfgName == 'Custom ...') {
      int i = 1;
      do {
        cfgName = 'Custom routine ' + i.toString();
        i++;
      } while (settings.findRoutineIndex(cfgName) != -1);

      if (settings.cps.length == 0) settings.addParam(gExerciseLib[0]);
      settings.addRoutine(Routine(cfgName,
          [Exercise(settings.cps[0].name, settings.cps[0].rounds, true)]));
    } else {
      Routine r = settings.getRoutineFromLib(cfgName)!;
      print('_addRoutine: Adding routine $cfgName');

      List<String> npExercises = settings.exercisesNotPresent(r);
      if (npExercises.length > 0) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text('Adding exercises'),
                  content: Text(
                      'The routine \'$cfgName\' includes some new exercises:\n\n- ' +
                          npExercises.join('\n- ') +
                          '\n\nAdding these to your exercise list!!'),
                ));
        npExercises.forEach((ex) {
          settings.addParam(settings.getExerciseFromLib(ex)!);
        });
      }

      settings.addRoutine(r);
    }

    _editRoutine(context, cfgName);
  }

  void _editRoutine(context, String cfg) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return EditRoutinePage(cfg: cfg);
      }),
    ).then((value) {
      setState(() {});
    });
  }
  */
}
