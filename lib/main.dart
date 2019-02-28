import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _path;
  File _cachedFile;



  Future<Null> uploadFile(String filepath)async{

    final ByteData byteData = await rootBundle.load(filepath);
    final Directory tempDir =Directory.systemTemp;
    final String filename = "${Random().nextInt(10000)}.jpg";
    final File file =File('${tempDir.path}/$filename');
    file.writeAsBytes(byteData.buffer.asInt8List(), mode: FileMode.write);

    final StorageReference ref =FirebaseStorage.instance.ref().child(filename);
    final StorageUploadTask task = ref.putFile(file);

    StorageTaskSnapshot storageTaskSnapshot = await task.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    _path =downloadUrl.toString();

    print(_path);
  }

  Future<Null> downloadFile(String httpPath)async{
      // Final means Const
      //Datatype in 2nd Position
      //Variable in  3rd position
        final RegExp regExp = RegExp('([^?/]*\.(jpg))');
        final String fileName =regExp.stringMatch(httpPath); 
        final Directory tempDir =Directory.systemTemp;
        final File file = File('${tempDir.path}/$fileName');

        final StorageReference ref = FirebaseStorage.instance.ref().child(fileName);
        final StorageFileDownloadTask downloadTask =ref.writeToFile(file);

        final int byteNumber = (await downloadTask.future).totalByteCount;

        print(byteNumber);
        setState(() => _cachedFile =file
        );



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Wrap(
              children: <Widget>[ Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: fileNames
                .map((name)=> GestureDetector(
                  onTap: ()async{
                    await uploadFile(name);
                  },
                  child: Image.asset(name,
                  width: 100.0,
                  ),
                )).toList(),
              ),
              ],
            ),
            SizedBox(height: 30.0,),
            Container(
              color: Colors.black,
              height: 150.0,
              width: 150.0,
              child: _path != null
                  ? Image.asset(_cachedFile.path)
                  : Container(),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
          await downloadFile(_path);
        },
        child: Icon(Icons.cloud_download),
      ),
      
    );
  }
}

List<String> fileNames =<String> [
  'assets/photos/wallpaper-1.jpg',
  'assets/photos/wallpaper-2.jpg',
  'assets/photos/wallpaper-3.jpg',
];