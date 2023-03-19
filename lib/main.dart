import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:meal_planner/services/database.dart';
import 'package:upgrader/upgrader.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:meal_planner/pages/authenticate_page.dart';
import 'package:meal_planner/pages/email_verify_page.dart';
import 'package:meal_planner/services/auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'firebase_options.dart';

import 'package:meal_planner/pages/home_page.dart';
import 'package:meal_planner/services/settings.dart';
import 'package:provider/provider.dart';

String appVersion = '';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  appVersion =
      'Version ' + packageInfo.version + ' +' + packageInfo.buildNumber;

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<YogaSettings>(create: (_) => YogaSettings()),
          ChangeNotifierProvider<GoogleSignInProvider>(
              create: (_) => GoogleSignInProvider()),
        ],
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User?>.value(
      value: AuthService().user,
      initialData: null,
      child: Center(
        child: SizedBox(
          width: kIsWeb ? 400 : double.infinity,
          height: kIsWeb ? 800 : double.infinity,
          child: MaterialApp(
            //title: 'Meal Planner',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: kIsWeb ? Wrapper() : UpgradeAlert(child: Wrapper()),
            debugShowCheckedModeBanner: false,
          ),
        ),
      ),
    );
  }
}

class Wrapper extends StatefulWidget {
  Wrapper({Key? key}) : super(key: key);

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  String _uidSignedIn = '';

  @override
  Widget build(BuildContext context) {
    final dynamic user = Provider.of<User?>(context);

    FirebaseAuth.instance.authStateChanges().listen(_authChangeHandler);

    return Consumer<YogaSettings>(builder: (context, settings, _) {
      return ((user != null) ? WaitLoad() : AuthenticatePage(ver: appVersion));
    });
  }

  Future _authChangeHandler(User? user) async {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    if (user == null) {
      print('_authChangeHandler: User is currently signed out!');
      _uidSignedIn = '';
      settings.loadComplete = false;
    } else {
      if (_uidSignedIn == user.uid) {
        // this is a duplicate sign in event, ignore it
        print(
            '_authChangeHandler: [DUPLICATE, ignoring] User ${user.email} ${user.uid} is signed in!');
        return;
      }

      print('_authChangeHandler: User ${user.email} ${user.uid} is signed in!');
      _uidSignedIn = user.uid;
      await _rightAfterSignIn(context, user);
    }
  }

  Future _rightAfterSignIn(context, user) async {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    print('_rightAfterSignIn: ${user.email} ${user.displayName}');

    settings.initSettings();

    String userName = user.displayName ?? user.email.split('@')[0];
    settings.setUser(userName, user.email, user.uid, user.photoURL ?? '',
        user.emailVerified);

    print(
        '_rightAfterSignIn: Signed in user ${settings.getUser()}, reading DB now ..');

    // read rest of the settings from DB
    await settings.loadSettingsFromDB();

    if (user.email == 'sandesh@gmail.com') settings.setSuperUser(true);

    // save all settings back to DB
    print('_rightAfterSignIn: saving to DB now ..');
    await settings.saveSettings();
    print('_rightAfterSignIn: saved to DB  ..');

    // cache details of all my meal plans
    await settings.getAllMealPlans();
    if (settings.getCurMpIndex() > settings.mealPlans.length) {
      print(
          'ERROR: curMpIndex ${settings.getCurMpIndex()}, mealplans ${settings.mealPlans.length}');
      settings.setCurMpIndex(0);
    }

    // cache all meals
    await settings.getAllMeals();

    // cache meal plan data for current meal plan
    await settings.getCurMealPlanData();

    // signal that loading is complete
    settings.loadComplete = true;

    await DBService(email: user.email).log({'type': 'login'});
  }
}

class WaitLoad extends StatefulWidget {
  const WaitLoad({super.key});

  @override
  State<WaitLoad> createState() => _WaitLoadState();
}

class _WaitLoadState extends State<WaitLoad> {
  Future<bool> _shared() async {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    while (!settings.loadComplete)
      await Future.delayed(Duration(milliseconds: 100));
    print(
        'WaitLoad: verified=${settings.getUser().verified}, loadComplete=${settings.loadComplete}');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    return FutureBuilder<bool>(
      future: _shared(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        Widget ret = Container();

        if (snapshot.hasData) {
          ret = (settings.getUser().verified
              ? MyHomePage(ver: appVersion)
              : EmailVerifyPage());
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
}
