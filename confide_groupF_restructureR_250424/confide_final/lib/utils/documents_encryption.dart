import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:encrypt/encrypt.dart' as enc;

class DocumentScreen extends StatefulWidget{
  const DocumentScreen({super.key});

  @override
  _DocumentScreenState createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {

  bool _isGranted =true;
  String filename = "demo.zip";

  // get from store database documents url
  final String _videoURL = "https:www.ddjfgdjfgdjf.com/aaj.mp4";
  final String _imageURL = "https:www.ddjfgdjfgdjf.com/aaj.jpg";
  final String _pdfURL = "https:www.ddjfgdjfgdjf.com/aaj.pdf";
  final String _zipURL = "https:www.ddjfgdjfgdjf.com/aaj.zip";

  Future<Directory?> get getAppDir async {
    final appDocDir = await getExternalStorageDirectory();
    return appDocDir;
  }

  Future<Directory> get getExternalVisibleDir async {
    if (await Directory('/storage/emulated/0/MyEncFolder').exists()) {
      final externalDir = Directory('/storage/emulated/0/MyEncFolder');
      return externalDir;
    } else {
      await Directory('/storage/emulated/0/MyEncFolder')
          .create(recursive: true);
      final externalDir = Directory('/storage/emulated/0/MyEncFolder');
      return externalDir;
    }
  }

  requestStoragePermission() async {
    if (!await Permission.storage.isGranted){
      PermissionStatus result = await Permission.storage.request();
      if (result.isGranted){
        setState(() {
          _isGranted = true;
        });
        _isGranted = false;
      }
    }
  }



 @override
  Widget build(BuildContext context) {
    requestStoragePermission();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("Download & Encrypt"),
              onPressed: () async {
                if (_isGranted){
                  Directory d = await getExternalVisibleDir;
                  // Directory hiddenDir = await getAppDir;
                  _downloadAndCreate(_zipURL, d, filename);
                } else {
                  print("No permission granted");
                  requestStoragePermission();
                }
              },
            ),
            ElevatedButton(
              child: const Text("Decrypt File"),
              onPressed: () async {
                if (_isGranted){
                  Directory d = await getExternalVisibleDir;
                  // Directory hiddenDir = await getAppDir;
                  _getNormalFile(d, filename);
                } else {
                  print("No permission granted");
                  requestStoragePermission();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

  _downloadAndCreate (String url, Directory d, filename) async {
    if (await canLaunch(url)){
      print("Data downloading...");
      var resp = await http.get(url as Uri);

      var encResult = _encryptData(resp.bodyBytes);
      String p = (await _writeData(encResult, '${d.path}/$filename.aes'));
      print("file encrypted successfll: $p");
    }else{
      print("can't launch url");
    }
  }

_getNormalFile (Directory d, filename) async {
  Uint8List encData = await _readData('${d.path}/$filename.aes');
  var plainData = await _decryptData(encData);
  String p = (await _writeData(plainData, '${d.path}/$filename'));
  print("file decrypted successfull: $p");
}

_encryptData(plainString){
  print("Encrypting File...");
  final encrypted = MyEncrypt.myEncrypter.encryptBytes(plainString, iv: MyEncrypt.myIv);
  return encrypted.bytes;
}

_decryptData(encData){
  print("File decryption in progress...");
  enc.Encrypted en = enc.Encrypted(encData);
  return MyEncrypt.myEncrypter.decryptBytes(en, iv: MyEncrypt.myIv);
}

Future<Uint8List> _readData(fileNameWithPath) async {
  print("Reading data...");
  File f = File(fileNameWithPath);
  return await f.readAsBytes();
}

Future<String> _writeData(dataToWrite, fileNameWithPath) async {
  print("Writting data...");
  File f = File(fileNameWithPath);
  await f.writeAsBytes(dataToWrite);
  return f.absolute.toString();
}

class MyEncrypt{
  static final myKey = enc.Key.fromUtf8('cdaccdaccdaccdaccdaccdaccdaccdac'); // 32 bit
  static final myIv = enc.IV.fromUtf8('cdaccdac12345678'); // 16 bit
  static final myEncrypter = enc.Encrypter(enc.AES(myKey)); // 32 bit
}




