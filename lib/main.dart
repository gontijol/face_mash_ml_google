// import 'package:camera/camera.dart';
// import 'package:face_detection/controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       home: const HomePage(),
//       debugShowCheckedModeBanner: false,
//       initialRoute: '/',
//       getPages: [
//         GetPage(name: '/', page: () => const HomePage()),
//         GetPage(
//             name: '/CameraPreviewImage',
//             page: () => const CameraPreviewImage()),
//         // Adicione outras rotas conforme necessário
//       ],
//     );
//   }
// }

// class HomePage extends GetView<HomeController> {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     Get.lazyPut(() => HomeController());
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'Face Detection',
//               style: TextStyle(fontSize: 20),
//             ),
//             ElevatedButton(
//               onPressed: () => Get.toNamed('/CameraPreviewImage'),
//               style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.all(Colors.blue),
//               ),
//               child: const Text('Take Picture',
//                   style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class CameraPreviewImage extends GetView<HomeController> {
//   const CameraPreviewImage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Obx(
//         () => controller.isLoading.value == false
//             ? Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   SizedBox(
//                     child: CameraPreview(controller.controller!),
//                   ),
//                   Center(
//                     child: CustomPaint(
//                       painter: PointsPainter(controller.referenceFacePoints),
//                       size: Size(Get.width, Get.height),
//                     ),
//                   ),
//                   Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         SizedBox(
//                           width: 100,
//                           height: 100,
//                           child: ElevatedButton(
//                             style: ButtonStyle(
//                               backgroundColor:
//                                   MaterialStateProperty.all(Colors.transparent),
//                             ),
//                             onPressed: () => controller.takePictureAndCompare(),
//                             child: Container(
//                               width: 20,
//                               height: 20,
//                               decoration: const BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 60),
//                       ],
//                     ),
//                   ),
//                 ],
//               )
//             : const Center(child: CircularProgressIndicator()),
//       ),
//     );
//   }
// }

// class PointsPainter extends CustomPainter {
//   final List<Offset> referenceFacePoints;

//   PointsPainter(this.referenceFacePoints);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()
//       ..color = Colors.black.withOpacity(0.2)
//       ..strokeWidth = 2.0
//       ..strokeCap = StrokeCap.round;

//     // Desenhando cada ponto de referência
//     for (var point in referenceFacePoints) {
//       point = Offset(
//         point.dx * 0.6,
//         point.dy * 0.5,
//       );
//       canvas.drawCircle(point, 4.0, paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }

import 'package:face_detection/faces.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FaceMeshDetectorView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
