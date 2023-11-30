import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todo_firebase/view_model/bloc/todo_cubit/todo_states.dart';
import 'package:todo_firebase/view_model/data/firebase/firebase.dart';
import '../../../model/statistics_madel.dart';
import '../../../model/task_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/todo_fire.dart';
import '../../data/local/shared_keys.dart';
import '../../data/local/shared_prefernce.dart';
import '../../data/network/dio_helper.dart';
import '../../data/network/end_points.dart';
import '../../utils/functions.dart';

class ToDoCubit extends Cubit<ToDoStates> {
  ToDoCubit() : super(ToDoInitialState());

  int currentIndex = 0;

  ToDoModel? todoModel;

  StatisticsModel? statistics;

  XFile? image;

  int total = 0;

  final List<String> statusItems = [
    'new',
    'outdated',
    'doing',
    'compeleted',
  ];

  String? statusValue;

  static ToDoCubit get(context) => BlocProvider.of<ToDoCubit>(context);

  var titleController = TextEditingController();
  var detailsController = TextEditingController();
  var startDateController = TextEditingController();
  var endDateController = TextEditingController();

  var editTitleController = TextEditingController();
  var editDetailsController = TextEditingController();
  var editStartDateController = TextEditingController();
  var editEndDateController = TextEditingController();

  var formKey = GlobalKey<FormState>();
  var editFormKey = GlobalKey<FormState>();

  ScrollController scrollController = ScrollController();

  bool isLoadingTasks = false;
  bool hasMoreTasks = true;

  void initController() {
    scrollController = ScrollController();
  }

  void disposeController() {
    scrollController.dispose();
  }

  void scrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.atEdge &&
          scrollController.position.pixels != 0 &&
          !isLoadingTasks &&
          hasMoreTasks) {
        print("you are in Bottom");
        fetchNewTasks();
      }
    });
  }

  void changeIndex(int index) {
    currentIndex = index;
    setData();
  }

  Future<void> fetchNewTasks() async {
    isLoadingTasks = true;
    //print(LocalData.get(key: SharedKeys.token));
    emit(GetMoreTasksLoadingState());
    await DioHelper.get(
      endPoint: EndPoints.tasks,
      parameters: {
        'page': (todoModel?.data?.meta?.currentPage ?? 0) + 1,
      },
      token: LocalData.get(
        key: SharedKeys.token,
      ),
    ).then((value) {
      isLoadingTasks = false;
      ToDoModel newToDoModel = ToDoModel.fromJson(value?.data);
      todoModel?.data?.meta = newToDoModel.data?.meta;
      todoModel?.data?.tasks?.addAll(newToDoModel.data?.tasks ?? []);
      if ((todoModel?.data?.meta?.lastPage ?? 0) ==
          (todoModel?.data?.meta?.currentPage ?? 0)) {
        hasMoreTasks = false;
      }
      emit(GetMoreTasksSuccessState());
    }).catchError((error) {
      isLoadingTasks = false;
      print(error);
      if (error is DioException) {
        print(error.response?.data);
      }
      emit(GetMoreTasksErrorState());
    });
  }

  Future<void> showStatistics() async {
    //print(LocalData.get(key: SharedKeys.token));
    emit(GetStatisticsLoadingState());
    await DioHelper.get(
      endPoint: EndPoints.statistics,
      token: LocalData.get(
        key: SharedKeys.token,
      ),
    ).then((value) {
      print(value?.data);
      statistics = StatisticsModel.fromJson(value?.data);
      total = (statistics?.data?.New ?? 0) +
          (statistics?.data?.doing ?? 0) +
          (statistics?.data?.outdated ?? 0) +
          (statistics?.data?.compeleted ?? 0);
      emit(GetStatisticsSuccessState());
    }).catchError((error) {
      print(error);
      if (error is DioException) {
        print(error.response?.data);
      }
      emit(GetStatisticsErrorState());
    });
  }

  void setData() {
    editTitleController.text =
        todoModel?.data?.tasks?[currentIndex].title! ?? "";
    editDetailsController.text =
        todoModel?.data?.tasks?[currentIndex].description! ?? "";
    editStartDateController.text =
        todoModel?.data?.tasks?[currentIndex].startDate! ?? "";
    editEndDateController.text =
        todoModel?.data?.tasks?[currentIndex].endDate! ?? "";
    statusValue = todoModel?.data?.tasks?[currentIndex].status! ?? "";
  }

  void clearAllData() {
    titleController.clear();
    detailsController.clear();
    startDateController.clear();
    endDateController.clear();
    statusValue = '';
    emit(ClearAllDataState());
  }

  void takePhotoFromUser() async {
    //emit(UploadImageLoadingState());
    var status = await Permission.storage.request();
    image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) {
      emit(UploadImageErrorState());
      Functions.showToast(message: "Choose an image");
      return;
    }
    emit(UploadImageSuccessState());
  }

  Future<void> addTaskFireStore() async {
    emit(AddNewTaskLoadingState());
    TodoFire todo = TodoFire(
      title: titleController.text,
      description: detailsController.text,
      startDate: startDateController.text,
      endDate: endDateController.text,
      status: statusValue,
      userId: LocalData.get(key: SharedKeys.uid),
    );
    if (image != null) {
      await uploadImage(
          image: image!,
          onSuccess: (photoLink) {
            todo.image = photoLink;
          });
    }
    await FirebaseFirestore.instance
        .collection(FirebaseKeys.tasks)
        .add(todo.toJson())
        .then((value) {
      print(value);
      emit(AddNewTaskSuccessState());
      getAllTasksFromFireStore();
    }).catchError((error) {
      print(error);
      emit(AddNewTaskErrorState());
      throw error;
    });
  }

  List<TodoFire> tasksFire = [];

  Future<void> getAllTasksFromFireStore() async {
    emit(GetAllTasksLoadingState());
    FirebaseFirestore.instance
        .collection(FirebaseKeys.tasks)
        .where('user_id', isEqualTo: LocalData.get(key: SharedKeys.uid))
        .snapshots()
        .listen((value) {
      tasksFire.clear();
      for (var i in value.docs) {
        tasksFire.add(TodoFire.fromJson(i.data(), id: i.reference));
      }
      emit(GetAllTasksSuccessState());
    }, onError: (error) {
      print(error);
      emit(GetAllTasksErrorState());
      throw error;
    });
  }

  TodoFire? currentTask;

  Future<void> getTaskFromFireStore() async {
    emit(GetTaskLoadingState());
    await tasksFire[currentIndex].id?.get().then((value) {
      currentTask = TodoFire.fromJson(value.data() as Map<String, dynamic>,
          id: value.reference);
      setDataFromFirebaseToControllers();
      emit(GetTaskSuccessState());
    }).catchError((error) {
      print(error);
      emit(GetTaskErrorState());
      throw error;
    });
  }

  void setDataFromFirebaseToControllers() {
    editTitleController.text = currentTask?.title! ?? "";
    editDetailsController.text = currentTask?.description! ?? "";
    editStartDateController.text = currentTask?.startDate! ?? "";
    editEndDateController.text = currentTask?.endDate! ?? "";
    statusValue = currentTask?.status! ?? "";
  }

  void setDataFromControllersToFireStore() {
    currentTask?.title = editTitleController.text;
    currentTask?.description = editDetailsController.text;
    currentTask?.startDate = editStartDateController.text;
    currentTask?.endDate = editEndDateController.text;
    currentTask?.status = statusValue;
  }

  Future<void> updateTaskFire() async {
    emit(UpdateTaskLoadingState());
    setDataFromControllersToFireStore();
    await currentTask?.id?.update(currentTask?.toJson() ?? {}).then((value) {
      emit(UpdateTaskSuccessState());
      getAllTasksFromFireStore();
    }).catchError((error) {
      print(error);
      emit(UpdateTaskSuccessState());
      throw error;
    });
  }

  Future<void> deleteTaskFire() async {
    emit(DeleteTaskLoadingState());
    await currentTask?.id?.delete().then((value) {
      emit(DeleteTaskSuccessState());
      getAllTasksFromFireStore();
    }).catchError((error) {
      print(error);
      emit(DeleteTaskErrorState());
      throw error;
    });
  }

  Future<void> uploadImage(
      {required XFile image, required Function(String) onSuccess}) async {
    emit(UploadImageLoadingState());
    await FirebaseStorage.instance
        .ref()
        .child('tasks/${image.name}')
        .putFile(File(image.path))
        .then((photo) async {
      await photo.ref.getDownloadURL().then((value) {
        print(value);
        onSuccess(value);
        emit(UploadImageSuccessState());
      });
    });
  }
}
