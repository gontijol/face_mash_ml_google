import 'package:face_detection/controllers/controller.dart';
import 'package:get/get.dart';

class PickImageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FaceController());
  }
}
