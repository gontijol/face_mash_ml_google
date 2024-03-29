import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class HomeController extends GetxController {
  CameraController? controller;
  Future<void>? initializeControllerFuture;
  final isLoading = true.obs;

  final FaceMeshDetector _detector =
      FaceMeshDetector(option: FaceMeshDetectorOptions.faceMesh);

  late List<Offset> referenceFacePoints;

  initializeCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(
      cameras[1],
      ResolutionPreset.max,
    );
    initializeControllerFuture = controller!.initialize();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (controller!.value.isInitialized) {
        timer.cancel();
        cameraIsLoading();
      }
    });
  }

  @override
  onInit() async {
    await initializeCamera();
    await loadReferenceFacePoints();
    super.onInit();
  }

  Future<void> takePictureAndCompare() async {
    try {
      if (referenceFacePoints.isEmpty) {
        // Carregar pontos de referência se ainda não estiverem carregados
        await loadReferenceFacePoints();
      }

      XFile picture = await controller!.takePicture();
      final inputImage = InputImage.fromFilePath(picture.path);
      await processImage(inputImage);
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> loadReferenceFacePoints() async {
    final ByteData data = await rootBundle.load('assets/image/face.jpeg');
    final List<int> bytes = data.buffer.asUint8List();
    final img.Image image = img.decodeImage(Uint8List.fromList(bytes))!;
    final int width = image.width;
    final int height = image.height;

    // Salvar o arquivo do ativo em um diretório temporário no dispositivo
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/face.jpeg');
    await file.writeAsBytes(bytes);

    // Criar uma instância de InputImage a partir do arquivo salvo
    final inputImage = InputImage.fromFile(file);
    final List<FaceMesh> meshes = await _detector.processImage(inputImage);
    if (meshes.isNotEmpty) {
      referenceFacePoints = meshes.first.points.map((point) {
        print('Point: ${point.x}, ${point.y}');
        return Offset(
          point.x,
          point.y,
        );
      }).toList();
    } else {
      throw Exception('No face detected in the reference image.');
    }
  }

  Future<void> processImage(InputImage inputImage) async {
    final List<FaceMesh> meshes = await _detector.processImage(inputImage);
    if (meshes.isNotEmpty) {
      final List<Offset> capturedFacePoints = meshes.first.points.map((point) {
        return Offset(point.x, point.y);
      }).toList();
      final double similarity = calculateSimilarity(capturedFacePoints);
      print('Similarity: $similarity');
      if (similarity > 0.8) {
        print('Match: Face detected matches reference image.');
      } else {
        print('No Match: Face detected does not match reference image.');
      }
    } else {
      print('No face detected in the captured image.');
    }
  }

  double calculateSimilarity(List<Offset> capturedFacePoints) {
    // Assume both lists have the same length
    double sumOfSquaredDifferences = 0.0;
    for (int i = 0; i < referenceFacePoints.length; i++) {
      final double xDiff = capturedFacePoints[i].dx - referenceFacePoints[i].dx;
      final double yDiff = capturedFacePoints[i].dy - referenceFacePoints[i].dy;
      final double squaredDifference = xDiff * xDiff + yDiff * yDiff;
      sumOfSquaredDifferences += squaredDifference;
    }
    final double meanSquaredDifference =
        sumOfSquaredDifferences / referenceFacePoints.length;
    return 1.0 / (1.0 + meanSquaredDifference);
  }

  cameraIsLoading() {
    if (initializeControllerFuture == null) {
      return isLoading.value = true;
    } else {
      return isLoading.value = false;
    }
  }

  @override
  void dispose() {
    _detector.close();
    super.dispose();
  }
}
