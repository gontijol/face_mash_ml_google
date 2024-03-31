import 'package:face_detection/routes/app_pages.dart';
import 'package:face_detection/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:loader_overlay/loader_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.home,
        getPages: AppPages.pages,
      ),
    );
  }
}
