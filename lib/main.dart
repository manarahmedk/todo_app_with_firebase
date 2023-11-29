import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_firebase/view/screens/splash_screen.dart';
import 'package:todo_firebase/view_model/bloc/auth_cubit/auth_cubit.dart';
import 'package:todo_firebase/view_model/bloc/observer.dart';
import 'package:todo_firebase/view_model/bloc/todo_cubit/todo_cubit.dart';
import 'package:todo_firebase/view_model/data/local/shared_prefernce.dart';
import 'package:todo_firebase/view_model/data/network/dio_helper.dart';

import 'firebase_options.dart';


  void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer=MyBlocObserver();
  await LocalData.init();
  //LocalData.clearData();
  //DioHelper.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context)=>ToDoCubit(),),
        BlocProvider(create: (context)=>AuthCubit(),),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SplashScreen(),
      ),
    );
  }
}

