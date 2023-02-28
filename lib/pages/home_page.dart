import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/pages/edit_settings_page.dart';
import 'package:meal_planner/pages/manage_plan_page.dart';
import 'package:meal_planner/pages/meals_page.dart';
import 'package:meal_planner/pages/stats_page.dart';
import 'package:meal_planner/services/auth.dart';
import 'package:meal_planner/services/meal_plan.dart';
import 'package:meal_planner/shared/constants.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:provider/provider.dart';

import 'package:meal_planner/services/settings.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AuthService _auth = AuthService();
  final _skey0 = GlobalKey();
  final _skey1 = GlobalKey();
  final _skey2 = GlobalKey();
  final _skey3 = GlobalKey();
  final _skey4 = GlobalKey();

  Future<bool> _shared() async {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    while (!settings.loadComplete)
      await Future.delayed(Duration(milliseconds: 100));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _shared(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        Widget ret = Container();

        if (snapshot.hasData) {
          ret = Consumer<YogaSettings>(builder: (context, settings, _) {
            return ShowCaseWidget(
              builder: Builder(builder: (context) {
                return Scaffold(
                  appBar: AppBar(
                    actions: [
                      Showcase(
                        key: _skey1,
                        description: 'Click here for the monthly view',
                        overlayPadding: const EdgeInsets.fromLTRB(-5, 0, 5, 0),
                        contentPadding: const EdgeInsets.all(20),
                        shapeBorder: const CircleBorder(),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.calendar_month),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                              return StatsPage();
                            }),
                          ).then((value) {
                            setState(() {});
                          });
                        },
                        icon: const Icon(
                            IconData(0xf5a9, fontFamily: 'MaterialIcons')),
                      ),
                      IconButton(
                        icon: const Icon(Icons.help_rounded),
                        onPressed: () {
                          setState(() {
                            ShowCaseWidget.of(context).startShowCase(
                                [_skey0, _skey1, _skey2, _skey3, _skey4]);
                          });
                        },
                      ),
                    ],
                    title: Text('Meal Planner',
                        style: const TextStyle(fontSize: 18)),
                  ),
                  drawer: _drawer(context, settings),
                  body: Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/background.jpg"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      MealsPage(),
                    ],
                  ),
                );
              }),
            );
          });
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
                      child: Text('Loading settings ...'),
                      alignment: Alignment.center,
                    )
                  ]));
        }
        return ret;
      },
    );
  }

  Widget _drawer(context, YogaSettings settings) {
    int index = settings.getCurMpIndex();
    print(
        '_drawer: curMpIndex=$index, MP len=${settings.mealPlans.length}, MPR len=${settings.getMprs().length}');
    String mpName = settings.mealPlans[index].name;
    MpRole mpRole = settings.getMprs()[index].mpRole;

    return Drawer(
      child: ListView(
        children: [
          _drawerHeader(context, settings),
          _drawerItem(context, '$mpName (${describeEnum(mpRole)})',
              Icon(Icons.note), () {}),
          Divider(),
          _drawerItem(context, 'Switch Meal plan', Icon(Icons.switch_account),
              _switchMealPlan),
          _drawerItem(
              context, 'Manage Meal plans', Icon(Icons.edit), _manageMealPlan),
          _drawerItem(context, 'Logout', Icon(Icons.logout), _logout),
          Divider(),
          _drawerItem(context, 'Settings', Icon(Icons.settings), _editSettings),
          _drawerItem(context, 'About', Icon(Icons.info), _about),
        ],
      ),
    );
  }

  Future<List<MealPlan>> getMealPlans(settings) async {
    List<MealPlanRole> mps = settings.getMprs();
    List<MealPlan> res = [];

    for (var i = 0; i < mps.length; i++) {
      MealPlan mp = await settings.getMealPlan(mps[i].mpid);
      res.add(mp);
    }

    return res;
  }

  void _switchMealPlan() async {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);

    List<MealPlan> mplist = await getMealPlans(settings);
    showMsg(context, mplist.map((e) => e.name).toList().join('\n'));
  }

  void _manageMealPlan() async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return ManagePage();
      }),
    ).then((value) {
      setState(() {});
    });
  }

  void _logout() async {
    GoogleSignInProvider _google =
        Provider.of<GoogleSignInProvider>(context, listen: false);
    await _auth.signOut();
    if (!kIsWeb) await _google.googleSignOut();
  }

  Widget _drawerItem(context, String text, Icon icon, fn) {
    return Material(
      child: InkWell(
        child: Container(
          margin: EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: Row(children: [
            Expanded(child: icon),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              flex: 4,
            ),
          ]),
        ),
        onTap: () {
          fn();
        },
      ),
    );
  }

  Widget _drawerHeader(context, settings) {
    var _photo = settings.getUser().photo;

    return Container(
      padding: EdgeInsets.all(20),
      color: Colors.lightBlue,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(
                    _photo), // AssetImage("assets/icon/yoga_icon_circular.png"),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            settings.getUser().name,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            settings.getUser().email,
            style: TextStyle(
              color: Colors.grey[200],
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          )
        ],
      ),
    );
  }

  Future _about() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    showAboutDialog(
      context: context,
      applicationVersion: 'Ver $version +$buildNumber',
      applicationIcon: Image.asset(
        "assets/icon/yoga_icon_circular.png",
        height: 40,
        width: 40,
      ),
      children: [
        RichText(
          text: TextSpan(
            text: 'https://sites.google.com/view/mealplanner',
            style: TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final url = 'https://sites.google.com/view/mealplanner';
                if (await canLaunchUrlString(url)) {
                  await launchUrlString(
                    url,
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
          ),
        ),
      ],
    );
  }

  void _editSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return EditSettingsPage();
      }),
    ).then((value) {
      setState(() {});
      Navigator.pop(context);
    });
  }
}
