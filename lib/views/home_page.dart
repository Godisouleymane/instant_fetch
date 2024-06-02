import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:instant_fetch/service/api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _urlController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isDownloading = false;
  String? _progress;

  void _downloadVideo() async {
    setState(() {
      _isDownloading = true;
      _progress = null;
    });

    try {
      final videoUrl = _urlController.text;
      print("Video URL: $videoUrl");
      final downloadUrl = await _apiService.downloadVideo(videoUrl);
      print("Download URL: $downloadUrl");
      await _downloadFile(downloadUrl!);
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download video')),
      );
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  Future<void> _downloadFile(String url) async {
    try {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          throw Exception('Could not get the directory');
        }
        final filePath = '${directory.path}/downloaded_video.mp4';
        print("File path: $filePath");

        final dio = Dio();
        try {
          await dio.download(
            url,
            filePath,
            onReceiveProgress: (received, total) {
              setState(() {
                _progress = "$received octets téléchargés";
              });
              print('Progression: $_progress');
            },
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Vidéo téléchargée à $filePath')),
          );
        } catch (e) {
          print("Erreur de téléchargement: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur de téléchargement de la vidéo')),
          );
        }


      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission denied')),
        );
      }
    } catch (e) {
      print("Permission error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get storage permission...')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: const Text('InstantFetch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: false,
        backgroundColor: Colors.red,
        elevation: 10,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(Icons.settings, color: Colors.white,),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Veuillez saisir le lien de la video à telecharger', style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold
            ),textAlign: TextAlign.center,),
            SizedBox(height: 30,),
            Container(
              padding: EdgeInsets.only(left: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _urlController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  counterStyle: TextStyle(color:Colors.white),
                  focusColor: Colors.white,
                  focusedBorder: InputBorder.none,
                  hintText: 'Lien de la video',
                  hintStyle: TextStyle(color: Colors.white, fontSize: 12)
                ),
              ),
            ),
            SizedBox(height: 30,),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              onPressed: _isDownloading ? null : _downloadVideo,
              child: _isDownloading
                  ? Text('Telechargement...')
                  : Text('Telecharger la video'),
            ),
            if (_progress != null) Text('Progress: $_progress', style: TextStyle(
              fontSize: 15,
            ),),
          ],
        )
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: (){},
          child: Icon(Icons.history, color: Colors.white,),
      ),
    );
  }
}
