import 'package:face_detection/controllers/controller.dart';
import 'package:face_detection/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';

class PickImageFilePage extends GetView<FaceController> {
  const PickImageFilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Detector'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text('Escolha uma imagem referência'),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white)),
                  onPressed: () async => {
                    context.loaderOverlay.show(),
                    await controller.initializeCamera(),
                    Get.toNamed(Routes.camera),
                    Future.delayed(const Duration(seconds: 1), () {
                      context.loaderOverlay.hide();
                    }),
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Icon(Icons.camera_alt, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text('Escolha uma imagem para comparar'),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue)),
                  onPressed: () async => {
                    context.loaderOverlay.show(),
                    await controller.initializeCamera(),
                    Get.toNamed(Routes.compareCamera),
                    Future.delayed(const Duration(seconds: 1), () {
                      context.loaderOverlay.hide();
                    }),
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Icon(Icons.camera_alt, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Center(
              child: Text(
                  'Similaridade com a imagem de referência: ${controller.result.value.toStringAsFixed(2)}%'),
            ),
          ),
          controller.result.value >= 80.0
              ? const Icon(Icons.check_box, size: 40, color: Colors.green)
              : const Icon(Icons.dangerous, size: 40, color: Colors.red),
        ],
      ),
    );
  }
}
