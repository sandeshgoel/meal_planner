import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:meal_planner/pages/home_page.dart';
import 'package:meal_planner/services/settings.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<YogaSettings>(create: (_) => YogaSettings()),
          //ChangeNotifierProvider<GoogleSignInProvider>(
          //    create: (_) => GoogleSignInProvider()),
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
    return Center(
      child: SizedBox(
        width: kIsWeb ? 400 : double.infinity,
        height: kIsWeb ? 800 : double.infinity,
        child: MaterialApp(
          //title: 'Meal Planner',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: Wrapper(),
          debugShowCheckedModeBanner: false,
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
  @override
  Widget build(BuildContext context) {
    return Consumer<YogaSettings>(builder: (context, settings, _) {
      return MyHomePage();
    });
  }
}
