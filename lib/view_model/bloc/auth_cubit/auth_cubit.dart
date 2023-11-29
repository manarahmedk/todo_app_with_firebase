import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:todo_firebase/view_model/utils/functions.dart';

import '../../data/firebase/firebase.dart';
import '../../data/local/shared_keys.dart';
import '../../data/local/shared_prefernce.dart';
import '../../data/network/dio_helper.dart';
import '../../data/network/end_points.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  static AuthCubit get(context) => BlocProvider.of<AuthCubit>(context);

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormState> formKey2 = GlobalKey<FormState>();

  TextEditingController nameController2 = TextEditingController();
  TextEditingController emailController2 = TextEditingController();
  TextEditingController passwordController2 = TextEditingController();
  TextEditingController confirmPasswordController2 = TextEditingController();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FirebaseAuth authProvider=  FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> loginWithFirebase() async {
    emit(LoginLoadingState());
    await authProvider.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    ).then((value){
      print(value.user?.email);
      print(value.user?.uid);
      saveDataFirebase(value);
      emit(LoginSuccessState());
    }).catchError((error){
      print(error);
      Functions.showToast(message: error.toString(),background: Colors.red);
      emit(LoginErrorState());
      throw error;
    });
  }

  void saveDataFirebase(UserCredential value) {
    LocalData.set(key: SharedKeys.uid, value: value.user?.uid);
    LocalData.set(key: SharedKeys.name, value: value.user?.displayName);
    LocalData.set(key: SharedKeys.email, value: value.user?.email);
  }

  Future<void> registerWithFirebase() async {
    emit(RegisterLoadingState());
    await authProvider.createUserWithEmailAndPassword(
      email: emailController2.text,
      password: passwordController2.text,
    ).then((value) async {
      print(value.user?.email);
      print(value.user?.uid);
      value.user?.updateDisplayName(nameController2.text);
      await addUserToFireStore(value);
      emit(RegisterSuccessState());
    }).catchError((error){
      print(error);
      emit(RegisterErrorState());
      throw error;
    });
  }

  Future<void> addUserToFireStore(UserCredential value) async {
    await db.collection(FirebaseKeys.users).doc(value.user?.uid).set({
      'name': nameController2.text,
      'email': emailController2.text,
      // 'password': passwordController2.text,
      // 'password_confirmation': confirmPasswordController2.text,
      'uid':value.user?.uid,
    });
  }

}
