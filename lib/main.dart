import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_management/src/core/background_helper.dart';
import 'package:user_management/src/features/users/views/user_view.dart';

Worker? worker;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  worker = await Worker.spawn();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (context, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const UserView(),
        );
      },
    );
  }
}
