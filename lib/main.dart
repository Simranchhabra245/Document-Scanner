import 'package:documentscanner2/Providers/documentProvider.dart';
import 'package:documentscanner2/custom/test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Splash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: DocumentProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.green,
            primaryColor: Colors.green,
            appBarTheme: AppBarTheme(color: ThemeData.dark().canvasColor),
            textSelectionColor: Colors.blueGrey,
            floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: ThemeData.dark().canvasColor)),
        home:
        // Test()
         Splash(),
      ),
    );
  }
}
