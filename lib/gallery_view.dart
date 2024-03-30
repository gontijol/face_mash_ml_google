import 'dart:convert';
import 'dart:io';

import 'package:face_detection/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class GalleryView extends StatefulWidget {
  const GalleryView(
      {super.key,
      required this.title,
      this.text,
      required this.onImage,
      required this.onDetectorViewModeChanged});

  final String title;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final Function()? onDetectorViewModeChanged;

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  File? _image;
  String? _path;
  final FaceMeshDetector _meshDetector =
      FaceMeshDetector(option: FaceMeshDetectorOptions.faceMesh);
  ImagePicker? _imagePicker;
  late List<FaceMeshPoint> referenceFacePoints;
  var _result = 0.0;
  late Rect ltrb;

  @override
  void initState() {
    super.initState();
    loadReferenceFacePoints();
    _imagePicker = ImagePicker();
  }

  Future<void> loadReferenceFacePoints() async {
    final ByteData data = await rootBundle.load('assets/image/face.jpeg');
    final List<int> bytes = data.buffer.asUint8List();
    // Salvar o arquivo do ativo em um diretório temporário no dispositivo
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/face.jpeg');
    await file.writeAsBytes(bytes);

    // Criar uma instância de InputImage a partir do arquivo salvo
    final inputImage = InputImage.fromFile(file);
    final List<FaceMesh> meshes = await _meshDetector.processImage(inputImage);

    ltrb = meshes.first.boundingBox;
    print('Bounding Box: $ltrb');
    if (meshes.isNotEmpty) {
      referenceFacePoints = meshes.first.points.map((point) {
        print('Point: ${point.x}, ${point.y}, ${point.z}');
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: widget.onDetectorViewModeChanged,
                child: Icon(
                  Platform.isIOS ? Icons.camera_alt_outlined : Icons.camera,
                ),
              ),
            ),
          ],
        ),
        body: _galleryBody());
  }

  Widget _galleryBody() {
    return ListView(shrinkWrap: true, children: [
      _image != null
          ? SizedBox(
              height: 400,
              width: 400,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.file(_image!),
                ],
              ),
            )
          : const Icon(
              Icons.image,
              size: 200,
            ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          onPressed: _getImageAsset,
          child: const Text('From Assets'),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: const Text('From Gallery'),
          onPressed: () => _getImage(ImageSource.gallery),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: const Text('Take a picture'),
          onPressed: () => _getImage(ImageSource.camera),
        ),
      ),
      if (_image != null)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
              '${_path == null ? '' : 'Image path: $_path'}\n\n${widget.text ?? ''}'),
        ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Result: $_result'),
      ),
    ]);
  }

  Future _getImage(ImageSource source) async {
    final pickedFile = await _imagePicker?.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = null;
        _path = null;
      });

      await _processFile(pickedFile.path);
      // Chamando a função de callback para enviar a imagem capturada para a outra view
      widget.onImage(InputImage.fromFilePath(pickedFile.path));
    }
  }

  double calculateSimilarity(
      List<FaceMeshPoint> capturedFacePoints, Rect ltrbDifference) {
    double sumOfSquaredDifferences = 0.0;

    if (capturedFacePoints.length != referenceFacePoints.length) {
      throw ArgumentError(
          'The number of points in capturedFacePoints must match the number of points in referenceFacePoints.');
    }
    final double ltrbDiffTop = ltrbDifference.top - ltrb.top;
    final double ltrbDiffLeft = ltrbDifference.left - ltrb.left;
    final double ltrbDiffRight = ltrbDifference.right - ltrb.right;
    final double ltrbDiffBottom = ltrbDifference.bottom - ltrb.bottom;
    print(
        'Calculate Box Difference: $ltrbDiffTop, $ltrbDiffLeft, $ltrbDiffRight, $ltrbDiffBottom');
    final calculateLtrbDifference =
        (ltrbDiffTop + ltrbDiffLeft + ltrbDiffRight + ltrbDiffBottom) / 3170;

    if (calculateLtrbDifference > 0.95 && calculateLtrbDifference <= 1.05) {
      print('Match: Face detected matches reference image.');
    } else {
      print('No Match: Face detected does not match reference image.');
    }

    print(
        'Calculate LTRB Difference: ${double.parse(calculateLtrbDifference.toStringAsFixed(2)).clamp(0.0, 100) * 100}%');
    for (int i = 0; i < capturedFacePoints.length; i++) {
      final double xDiff = capturedFacePoints[i].x - referenceFacePoints[i].x;
      final double yDiff = capturedFacePoints[i].y - referenceFacePoints[i].y;
      final double zDiff = capturedFacePoints[i].z - referenceFacePoints[i].z;

      final int indexDiff =
          (capturedFacePoints[i].index - referenceFacePoints[i].index).abs();

      final double squaredDifference =
          xDiff * xDiff + yDiff * yDiff + zDiff * zDiff + indexDiff * indexDiff;

      sumOfSquaredDifferences += squaredDifference;
    }

    final double meanSquaredDifference =
        sumOfSquaredDifferences / capturedFacePoints.length;

    // Defina um limiar adequado aqui
    const double threshold = 1000.0;
    final double similarity = (meanSquaredDifference / threshold) * 0.065;

    return similarity.clamp(0.0, 100);
  }

  Future _getImageAsset() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final assets = manifestMap.keys
        .where((String key) => key.contains('images/'))
        .where((String key) =>
            key.contains('.jpg') ||
            key.contains('.jpeg') ||
            key.contains('.png') ||
            key.contains('.webp'))
        .toList();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select image',
                    style: TextStyle(fontSize: 20),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.7),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (final path in assets)
                            GestureDetector(
                              onTap: () async {
                                Navigator.of(context).pop();
                                _processFile(await getAssetPath(path));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(path),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel')),
                ],
              ),
            ),
          );
        });
  }

  compareFaces(List<FaceMeshPoint> detectedPoints, Rect detectedLtrb) {
    final double similarity = calculateSimilarity(detectedPoints, detectedLtrb);
    print('Similarity: $similarity');
    if (similarity >= 90) {
      print('Match: Face detected matches reference image. ');
    } else {
      print('No Match: Face detected does not match reference image.');
    }
    setState(() {
      _result = similarity;
    });
  }

  Future _processFile(String path) async {
    setState(() {
      _image = File(path);
    });
    _path = path;
    final inputImage = InputImage.fromFilePath(path);
    final List<FaceMesh> meshes = await _meshDetector.processImage(inputImage);
    if (meshes.isNotEmpty) {
      final List<FaceMeshPoint> capturedFacePoints;
      var captureLtrb = meshes.first.boundingBox;
      if (meshes.isNotEmpty) {
        capturedFacePoints = meshes.first.points.map((point) {
          print('Point: ${point.x}, ${point.y}, ${point.z}');
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
      print('Face detected in the captured image.');
    } else {
      print('No face detected in the captured image.');
    }
    widget.onImage(inputImage);
  }
}
