import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:music_app/audio_playing%20screen.dart';
import 'package:music_app/const/audio_link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

/*For encrpyting a file from storage you must add this line in application tag
android:requestLegacyExternalStorage="true"
 *********   and don't forget add this lines too ***********
 <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>*/
class EncryptDecrypt extends StatefulWidget {
  const EncryptDecrypt({Key? key}) : super(key: key);

  @override
  State<EncryptDecrypt> createState() => _EncryptDecryptState();
}

class _EncryptDecryptState extends State<EncryptDecrypt> {
  final _audioPlayer = AudioPlayer();
  bool _isGranted = true;

  List<dynamic> audioList = [];

  readAudio() async {
    await DefaultAssetBundle.of(context)
        .loadString('json/audio.json')
        .then((value) {
      setState(() {
        audioList = json.decode(value);
      });
    });
  }

  Future<Directory?> get getAppDir async {
    final appDocDir = await getExternalStorageDirectory();
    return appDocDir;
  }

  Future<Directory?> get getExternalVisibleDir async {
    if (await Directory(
            '/storage/emulated/0/Android/data/com.example.music_app/MyEncFolder')
        .exists()) {
      final externalDir = Directory(
          '/storage/emulated/0/Android/data/com.example.music_app/MyEncFolder');
      return externalDir;
    } else {
      await Directory(
              '/storage/emulated/0/Android/data/com.example.music_app/MyEncFolder')
          .create(recursive: true);
      final externalDir = Directory(
          '/storage/emulated/0/Android/data/com.example.music_app/MyEncFolder');
      return externalDir;
    }
  }

  requestStoragePermission() async {
    if (!await Permission.storage.isGranted) {
      PermissionStatus result = await Permission.storage.request();
      if (result.isGranted) {
        setState(() {
          _isGranted = true;
        });
      } else {
        _isGranted = false;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
    readAudio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18.0),
              child: Text(
                'Audio File Encryption and Decryption',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: audioList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AudioPlayingScreen(
                            audioData: audioList, index: index),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ListTile(
                        leading: InkWell(
                          onTap: () async {
                            if (_isGranted) {
                              Directory? d = await getExternalVisibleDir;
                              _getNormalFile(d, fileName[index]);
                            } else {
                              print('No Permission Granted');
                              requestStoragePermission();
                            }
                          },
                          child: const Card(
                            elevation: 10,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'For Decrypt\nClick me',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                        tileColor: Colors.tealAccent.shade100,
                        title: Text(audioList[index]['title']),
                        trailing: InkWell(
                            onTap: () async {
                              if (_isGranted) {
                                Directory? d = await getExternalVisibleDir;
                                _downloadAndCreate(
                                    audioList[index]['audio_source'],
                                    d,
                                    '${audioList[index]['title']}.mp3');
                              } else {
                                print('No Permission Granted');
                                requestStoragePermission();
                              }
                            },
                            child: const Icon(
                              Icons.download,
                              color: Colors.red,
                            )),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),


    );
  }

  void _downloadAndCreate(
      String audioUrl, Directory? d, String fileName) async {
    bool isDownloaded = await checkIfFileExists('${d!.path}/$fileName');
    if (isDownloaded) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('File already downloaded!!!'),
        duration: Duration(
          seconds: 1,
        ),
      ));
    } else {
      if (await canLaunchUrl(Uri.parse(audioUrl))) {
        print('Data downloading...');
        var resp = await http.get(Uri.parse(audioUrl));
        var encResult = _encryptData(resp.bodyBytes);
        String p = await _writeData(encResult, '${d.path}/$fileName.aes');
        print('File Encrypted successfully...$p');
      } else {
        print('Can\'t launch url');
      }
    }
  }

void _getNormalFile(Directory? d, String fileName) async {
    Uint8List encData = await _readData('${d!.path}/$fileName.aes');
    var plainData = await _decryptData(encData);
    print('File Decrypted Successfully... ');

  }

  _encryptData(Uint8List plainString) {
    print('Encrypting File...');
    final encrypted =
        MyEncrypt.myEncrypter.encryptBytes(plainString, iv: MyEncrypt.myIv);

    return encrypted.bytes;
  }

  _writeData(encResult, String fileNamedWithPath) async {
    print('Writting data...');
    File f = File(fileNamedWithPath);
    await f.writeAsBytes(encResult);
    return f.absolute.toString();
  }

  _decryptData(Uint8List encData) {
    print('File decryption in progress...');
    enc.Encrypted en = enc.Encrypted(encData);
    return MyEncrypt.myEncrypter.decryptBytes(en, iv: MyEncrypt.myIv);
  }

  _readData(String fileNamedWithPath) async {
    print('Reading data...');
    File f = File(fileNamedWithPath);
    return await f.readAsBytes();
  }

  Future<bool> checkIfFileExists(String filePath) async {
    File file = File(filePath);
    return await file.exists();
  }
}

class MyEncrypt {
  static final myKey = enc.Key.fromUtf8('AshikujjamanAshikujjamanKazol299');
  static final myIv = enc.IV.fromUtf8('KazolAshikujjama');
  static final myEncrypter = enc.Encrypter(enc.AES(myKey));
}
