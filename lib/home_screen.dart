import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

import 'main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  CameraImage? cameraImage;
  CameraController? cameraController;
  String output = '';
    final interpreter = await tfl.Interpreter.fromAsset('your_model.tflite');

  loadCamera(){
    cameraController =  CameraController(cameras![0],ResolutionPreset.medium);

    cameraController!.initialize().then((value) {
      if (!mounted){
        return;
      } else{
        setState(() {
         cameraController!.startImageStream((imageStream) {
           cameraImage = imageStream;
           print("loading ccc");
           runModel();
         });
        });
      }

    });
  }

  runModel() async{
    if(cameraImage != null){
      var prediction = await Tflite.runModelOnFrame(
          bytesList: cameraImage!.planes.map((plane)  {
            return plane.bytes;
          }).toList(),
        imageHeight: cameraImage!.height,
        imageWidth: cameraImage!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true);
      prediction!.forEach((element) {
        setState(() {
          output = element['label'];
          print("--working--");
        });
      });
    }
  }

  loadModel() async{

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Detection Camera Live")
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height*0.7,
                width: MediaQuery.of(context).size.width*0.7,
                child:!cameraController!.value.isInitialized?const SizedBox():
                AspectRatio(aspectRatio: cameraController!.value.aspectRatio,
                child: CameraPreview(cameraController!),
                )
                ,
              ),
            ),
            Text(output)
          ],
        ),
      ),
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCamera();
    loadModel();
  }
}
