import 'package:file_picker/file_picker.dart';
import 'package:finstagram/pages/feed_page.dart';
import 'package:finstagram/pages/profile_page.dart';
import 'package:finstagram/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  int _currentPage = 0;
  final List<Widget> _pages = const [
    FeedPage(),
    ProfilePage(),
  ];
  FirebaseService? _firebaseService;

  @override
  void initState() {
    super.initState();
    _firebaseService = GetIt.instance.get<FirebaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          "Finstagram",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              _createPost();
            },
            child: const Icon(
              Icons.add_a_photo,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: GestureDetector(
              onTap: () {
                _firebaseService!.logoutUser();
                Navigator.popAndPushNamed(context, 'login');
              },
              child: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomNavigationBar(),
      body: _pages[_currentPage],
    );
  }

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentPage,
      onTap: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          label: "Feed",
          icon: Icon(Icons.feed),
        ),
        BottomNavigationBarItem(
          label: "Profile",
          icon: Icon(Icons.account_box),
        ),
      ],
    );
  }

  void _createPost() async {
    bool storagePermission = await _requestStoragePermission();
    if(storagePermission) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
      if(result != null) {
        File image = File(result.files.first.path!);
        _firebaseService!.createPost(image: image);
      }
    }
    else {
      print('Storage permission was not granted');
    }
  }

  Future<bool> _requestStoragePermission() async {
    var status = await Permission.storage.status;
    if(status.isGranted) {
      return true;
    }
    else {
      var result = await Permission.storage.request();
      if(result.isGranted) {
        return true;
      }
      else {
        return false;
      }
    }
  }
}