import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:todo_firebase/view/screens/login_screen.dart';
import 'package:todo_firebase/view_model/data/local/shared_prefernce.dart';
import '../../model/task_model.dart';
import '../../model/todo_fire.dart';
import '../../view_model/bloc/todo_cubit/todo_cubit.dart';
import '../../view_model/bloc/todo_cubit/todo_states.dart';
import '../../view_model/utils/colors.dart';
import '../../view_model/utils/lottie.dart';
import '../../view_model/utils/navigation.dart';
import '../components/builders/shimmer_tasks.dart';
import '../components/builders/task_builder.dart';
import '../components/widgets/text_custom.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

class ToDoScreen extends StatelessWidget {
  const ToDoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = ToDoCubit.get(context);
    return BlocProvider.value(
      value: ToDoCubit.get(context)
        ..getAllTasksFromFireStore()
        ..initController()
        ..scrollListener(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.orange,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
          title: const TextCustom(
            text: 'To Do App',
          ),
          actions: [
            IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                LocalData.clearData();
                Navigation.pushAndRemove(context, LoginScreen());
              },
              icon: const Icon(
                Icons.exit_to_app_rounded,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: BlocConsumer<ToDoCubit, ToDoStates>(
          listener: (context, state) {},
          builder: (context, state) {
            return Visibility(
              visible: state is! GetAllTasksLoadingState,
              //replacement: const ShimmerTasks(),
              child: Column(
                children: [
                  Expanded(
                    child: Visibility(
                      visible: cubit.tasksFire.isNotEmpty,
                      replacement: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.network(AppLotties.empty),
                            const TextCustom(
                              text: 'No Tasks Added !',
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: AppColors.orange,
                            ),
                          ],
                        ),
                      ),
                      child: RefreshIndicator(
                        onRefresh: () async {
                          cubit.hasMoreTasks = true;
                          cubit.isLoadingTasks = false;
                          await cubit.getAllTasksFromFireStore();
                        },
                        child: ListView.separated(
                          controller: cubit.scrollController,
                          itemBuilder: (context, index) {
                            return TaskBuilder(
                              taskModel: cubit.tasksFire[index],
                              onTap: () {
                                cubit.changeIndex(index);
                                Navigation.push(
                                  context,
                                  EditTaskScreen(
                                    taskModel: cubit.tasksFire[index],
                                  ),
                                );
                              },
                            );
                          },
                          separatorBuilder: (context, index) => const SizedBox(
                            height: 8,
                          ),
                          itemCount: cubit.tasksFire.length,
                        ),
                      ),
                    ),
                  ),
                  if (cubit.isLoadingTasks)
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(),
                    ),
                  // if(cubit.hasMoreTasks==false && cubit.todoModel?.data?.tasks?.isNotEmpty==true)
                  //   const Padding(
                  //     padding:  EdgeInsets.all(12.0),
                  //     child: TextCustom(text: 'No more Tasks to load!',color: Colors.black,),
                  //   ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigation.push(context, AddTaskScreen());
          },
          backgroundColor: AppColors.orange,
          child: const Icon(
            Icons.add,
          ),
        ),
      ),
    );
  }
}
