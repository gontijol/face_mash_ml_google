import 'package:face_detection/pages/camera_compare/page.dart';
import 'package:face_detection/pages/camera_reference/page.dart';
import 'package:face_detection/pages/home/bindings.dart';
import 'package:face_detection/pages/home/page.dart';
import 'package:face_detection/routes/app_routes.dart';
import 'package:get/route_manager.dart';

abstract class AppPages {
  static final pages = [
    // GetPage(
    //   name: Routes.initial,
    //   page: () => const SplashScreenPage(),
    //   binding: SplashBinding(),
    //   transitionDuration: const Duration(milliseconds: 500),
    // ),

    GetPage(
      name: Routes.home,
      page: () => const PickImageFilePage(),
      binding: PickImageBinding(),
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.camera,
      page: () => const CameraPreviewPage(),
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.compareCamera,
      page: () => const CompareCameraPreviewPage(),
      transitionDuration: const Duration(milliseconds: 500),
    ),
  ];
}
