import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:image_picker/image_picker.dart';

class FaceController extends GetxController {
  late CameraController cameraController;
  final Rx<File> _image = File('').obs;
  final _path = ''.obs;
  final FaceMeshDetector _meshDetector =
      FaceMeshDetector(option: FaceMeshDetectorOptions.faceMesh);
  late ImagePicker _imagePicker;
  late RxList referenceFacePoints = [].obs;
  final result = 0.0.obs;
  late Rect ltrb;

  @override
  onInit() async {
    _imagePicker = ImagePicker();
    // await loadReferenceFacePoints();
    super.onInit();
  }

  initializeCamera() async {
    final cameras = await availableCameras();
    cameraController = CameraController(
      cameras[1],
      ResolutionPreset.high,
    );
    await cameraController.initialize();
  }

  takeAndProcessPicture() async {
    try {
      final XFile picture = await cameraController.takePicture();
      final inputImage = InputImage.fromFilePath(picture.path);

      final List<FaceMesh> meshes =
          await _meshDetector.processImage(inputImage);

      ltrb = meshes.first.boundingBox;
      if (meshes.isNotEmpty) {
        referenceFacePoints.value = meshes.first.points.map((point) {
          return FaceMeshPoint(
            index: point.index,
            x: point.x,
            y: point.y,
            z: point.z,
          );
        }).toList();
      } else {
        throw Exception('No face detected in the reference image.');
      }
    } catch (e) {
      if (kDebugMode) {
        Get.back();
        print(e);
      }
    }
    Future.delayed(const Duration(seconds: 3), () {});
  }

  takeAndCompareImage() async {
    final XFile picture = await cameraController.takePicture();
    await _processFile(picture.path);
  }

  // Future<void> loadReferenceFacePoints() async {
  //   final ByteData data = await rootBundle.load('assets/image/face.jpeg');
  //   final List<int> bytes = data.buffer.asUint8List();
  //   // Salvar o arquivo do ativo em um diretório temporário no dispositivo
  //   final tempDir = await getTemporaryDirectory();
  //   final file = File('${tempDir.path}/face.jpeg');
  //   await file.writeAsBytes(bytes);

  //   // Criar uma instância de InputImage a partir do arquivo salvo
  //   final inputImage = InputImage.fromFile(file);
  //   final List<FaceMesh> meshes = await _meshDetector.processImage(inputImage);

  //   ltrb = meshes.first.boundingBox;

  //   if (meshes.isNotEmpty) {
  //     referenceFacePoints.value = meshes.first.points.map((point) {
  //       return FaceMeshPoint(
  //         index: point.index,
  //         x: point.x,
  //         y: point.y,
  //         z: point.z,
  //       );
  //     }).toList();
  //   } else {
  //     throw Exception('No face detected in the reference image.');
  //   }
  // }

  double calculateSimilarity(
      List<FaceMeshPoint> capturedFacePoints, Rect ltrbDifference) {
    // Defina pesos para diferentes componentes
    const double pointsWeight = 0.3;
    const double ltrbWeight = 0.7;

    // Inicialize as diferenças
    double pointsDifference = 0.0;
    double ltrbDiff = 0.0;

    // Calcular a diferença na localização dos pontos
    for (int i = 0; i < capturedFacePoints.length; i++) {
      pointsDifference += sqrt(
          pow(capturedFacePoints[i].x - referenceFacePoints[i].x, 2) +
              pow(capturedFacePoints[i].y - referenceFacePoints[i].y, 2) +
              pow(capturedFacePoints[i].z - referenceFacePoints[i].z, 2));
    }

    // Normalizar a diferença na localização dos pontos
    pointsDifference /= capturedFacePoints.length;

    // Calcular a diferença nas dimensões do retângulo delimitador
    double ltrbDiffTop = sqrt(pow(ltrbDifference.top - ltrb.top, 2));
    double ltrbDiffLeft = sqrt(pow(ltrbDifference.left - ltrb.left, 2));
    double ltrbDiffRight = sqrt(pow(ltrbDifference.right - ltrb.right, 2));
    double ltrbDiffBottom = sqrt(pow(ltrbDifference.bottom - ltrb.bottom, 2));

    double maxLTRBDifference =
        max(max(ltrbDiffTop, ltrbDiffLeft), max(ltrbDiffRight, ltrbDiffBottom));

    ltrbDiff =
        (ltrbDiffTop + ltrbDiffLeft + ltrbDiffRight + ltrbDiffBottom) / 4;

    // Calcular a similaridade combinando as duas diferenças
    double similarity =
        (pointsWeight * pointsDifference + ltrbWeight * ltrbDiff);

    // Normalizar a similaridade para uma escala de 0 a 100
    double maxPointsDifference = 100.0;

    similarity =
        (1 - (similarity / (maxPointsDifference + maxLTRBDifference))) * 100;

    // Certifique-se de que a similaridade esteja no intervalo [0, 100]
    similarity = similarity.clamp(0.0, 100.0);

    return similarity;
  }

  compareFaces(List<FaceMeshPoint> detectedPoints, Rect detectedLtrb) {
    final double similarity = calculateSimilarity(detectedPoints, detectedLtrb);

    if (similarity >= 90) {
    } else {}

    result.value = similarity;
  }

  Future _processFile(String path) async {
    _image.value = File(path);

    _path.value = path;
    final inputImage = InputImage.fromFilePath(path);
    final List<FaceMesh> meshes = await _meshDetector.processImage(inputImage);
    if (meshes.isNotEmpty) {
      final List<FaceMeshPoint> capturedFacePoints;
      var captureLtrb = meshes.first.boundingBox;
      if (meshes.isNotEmpty) {
        capturedFacePoints = meshes.first.points.map((point) {
          return FaceMeshPoint(
            index: point.index,
            x: point.x,
            y: point.y,
            z: point.z,
          );
        }).toList();
      } else {
        throw Exception('No face detected in the reference image.');
      }
      Future.delayed(const Duration(seconds: 3), () {
        compareFaces(capturedFacePoints, captureLtrb);
      });
    } else {}
  }

  Future getImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);

    if (pickedFile == null) {
      return;
    }
    try {
      await _processFile(pickedFile.path);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    Future.delayed(const Duration(seconds: 3), () {});
    // InputImage.fromFilePath(pickedFile.path);
  }

  Future getReferenceImage(
    ImageSource source,
  ) async {
    final pickedFile = await _imagePicker.pickImage(source: source);
    final inputImage = InputImage.fromFilePath(pickedFile!.path);

    final List<FaceMesh> meshes = await _meshDetector.processImage(inputImage);

    ltrb = meshes.first.boundingBox;
    if (meshes.isNotEmpty) {
      referenceFacePoints.value = meshes.first.points.map((point) {
        return FaceMeshPoint(
          index: point.index,
          x: point.x,
          y: point.y,
          z: point.z,
        );
      }).toList();
    } else {
      throw Exception('No face detected in the reference image.');
    }
    Future.delayed(const Duration(seconds: 3), () {});
    // InputImage.fromFilePath(pickedFile.path);
  }

  clearValues() {
    result.value = 0.0;
  }
}
