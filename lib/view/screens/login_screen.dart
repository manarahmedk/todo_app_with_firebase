import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_firebase/view/screens/register_screen.dart';
import 'package:todo_firebase/view/screens/statistics_screen.dart';
import '../../view_model/bloc/auth_cubit/auth_cubit.dart';
import '../../view_model/utils/colors.dart';
import '../../view_model/utils/navigation.dart';
import '../components/widgets/my_text_form_field.dart';
import '../components/widgets/text_custom.dart';


class LoginScreen extends StatelessWidget {

  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {},
            builder: (context, state) {
              var cubit = AuthCubit.get(context);
              return ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Image.network(
                    'https://cdn.icon-icons.com/icons2/1543/PNG/512/todo_107314.png',
                    height: 200,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const TextCustom(
                    text: 'Login',
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Form(
                    key: cubit.formKey,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        MyTextFormField(
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          controller: cubit.emailController,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if ((value ?? '').isEmpty) {
                              return 'Please, Enter your Email';
                            }
                            return null;
                          },
                        ),
                        MyTextFormField(
                          hintText: 'Password',
                          keyboardType: TextInputType.text,
                          controller: cubit.passwordController,
                          suffixIcon: Icons.remove_red_eye,
                          obscureText: obscureText,
                          secondSuffixIcon: Icons.visibility_off,
                          validator: (value) {
                            if ((value ?? '').isEmpty) {
                              return 'Please, Enter your Password';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: 350,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (cubit.formKey.currentState!.validate()) {
                          cubit.loginWithFirebase().then((value) {
                            Navigation.pushAndRemove(context, const StatisticsScreen());
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: AppColors.orange,
                        minimumSize: const Size(double.infinity, 50),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      child: const TextCustom(
                        text: 'Login',
                        fontSize: 15,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const TextCustom(
                        text: 'Don\'t have an account ?  ',
                        fontSize: 15,
                        color: AppColors.grey,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigation.pushAndRemove(context, RegisterScreen());
                        },
                        child: const TextCustom(
                          text: 'Register',
                          fontSize: 17,
                          color: AppColors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
