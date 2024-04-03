import 'package:camera/camera.dart';
import 'package:face_detection/controllers/controller.dart';
import 'package:face_detection/painters/face_painter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';

class CameraPreviewPage extends GetView<FaceController> {
  const CameraPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Preview'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Obx(
            () => !controller.isLoadingCamera.value
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 0.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CameraPreview(
                          controller.cameraController,
                          child: Positioned.fill(
                            child: GestureDetector(
                              onTapDown: (details) {
                                // Adicione aqui a lógica para processar o toque
                                // e mover o pintor para a posição do toque
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Text(
                                      'Ajuste o rosto na área delimitada',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20)),
                                  CustomPaint(
                                    painter: RealisticFacePainter(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const CircularProgressIndicator(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.white,
                  ),
                  shadowColor: MaterialStateProperty.all(
                    Colors.blue,
                  ),
                ),
                onPressed: () async {
                  context.loaderOverlay.show();
                  await controller.takeAndProcessPicture();
                  Future.delayed(const Duration(seconds: 3), () {
                    context.loaderOverlay.hide();
                    Get.back();
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Icon(Icons.camera_alt, color: Colors.blue),
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.white,
                  ),
                  shadowColor: MaterialStateProperty.all(
                    Colors.blue,
                  ),
                ),
                onPressed: () async => controller.changeCamera(),
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Icon(Icons.cameraswitch, color: Colors.blue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
