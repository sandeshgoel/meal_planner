import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/pages/edit_settings_page.dart';
import 'package:meal_planner/pages/manage_plan_page.dart';
import 'package:meal_planner/pages/manage_users_page.dart';
import 'package:meal_planner/pages/meal_library_page.dart';
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
  final String ver;
  MyHomePage({required this.ver, Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AuthService _auth = AuthService();

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
            MealPlan mp = settings.mealPlans[settings.getCurMpIndex()];
            int shared =
                mp.admins.length + mp.members.length + mp.viewers.length - 1;
            List<String> slist = mp.admins + mp.members;

            return ShowCaseWidget(
              builder: Builder(builder: (context) {
                return Scaffold(
                  appBar: AppBar(
                    actions: [
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
                    ],
                    title: Tooltip(
                      message: (shared > 0)
                          ? 'This plan has been shared with ' +
                              slist.join(', ') +
                              '.'
                          : 'This plan has not been shared!',
                      child: Row(
                        children: [
                          Icon((shared > 0) ? Icons.group : Icons.group_off),
                          SizedBox(width: 10),
                          Text(mp.name, style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
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
              ],
            ),
          );
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
          _drawerItem(
              context,
              'Manage Meal plans (${settings.getMprs().length})',
              Icon(Icons.edit),
              _manageMealPlan),
          _drawerItem(context, 'Logout', Icon(Icons.logout), _logout),
          Divider(),
          _drawerItem(context, 'Settings', Icon(Icons.settings), _editSettings),
          _drawerItem(
              context, 'Meals Library', Icon(Icons.library_add), _mealLib),
          (settings.getSuperUser()
              ? _drawerItem(
                  context, 'Manage Users', Icon(Icons.person), _manageUsers)
              : Container()),
          _drawerItem(context, 'Refresh settings', Icon(Icons.refresh),
              _refreshSettings),
          Divider(),
          _drawerItem(context, 'About', Icon(Icons.info), _about),
          _drawerItem(context, 'Sandesh Goel, ${widget.ver}',
              Icon(Icons.copyright), () {}),
        ],
      ),
    );
  }

  Future _refreshSettings() async {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);

    await settings.refreshCache();
    showToast(context, 'Refresh completed');
    setState(() {});
  }

  void _manageUsers() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return ManageUsers();
      }),
    ).then((value) {
      setState(() {});
    });
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

  void _manageMealPlan() async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return ManagePage();
      }),
    ).then((value) {
      setState(() {});
      Navigator.pop(context);
    });
  }

  void _mealLib() async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return MealLibrary();
      }),
    ).then((value) {
      setState(() {});
      Navigator.pop(context);
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
                    image: (_photo == '')
                        ? AssetImage("assets/icon/meal_easy_icon.png")
                            as ImageProvider
                        : NetworkImage(_photo),
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
              ),
            ] +
            (settings.getSuperUser()
                ? [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'SUPERUSER',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]
                : []),
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
        "assets/icon/meal_easy_icon.png",
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
