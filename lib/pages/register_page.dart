import 'package:finstagram/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage> {
  late double _deviceHeight, _deviceWidth;
  final _registerFormKey = GlobalKey<FormState>();
  FirebaseService? _firebaseService;
  String? _name, _email, _password;
  File? _image;

  @override
  void initState() {
    super.initState();
    _firebaseService = GetIt.instance.get<FirebaseService>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.12),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _registerTitle(),
                _registerImage(),
                _registerForm(),
                _registerButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _registerTitle() {
    return const Text(
      "Finstagram",
      style: TextStyle(
        color: Colors.black,
        fontSize: 40,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _registerImage() {
    // todo: change this networkimage for an image stored in assets
    var imageProvider = _image != null ? FileImage(_image!) : const NetworkImage("https://as2.ftcdn.net/v2/jpg/03/49/49/79/1000_F_349497933_Ly4im8BDmHLaLzgyKg2f2yZOvJjBtlw5.jpg");

    return GestureDetector(
      onTap: () async {
        bool storagePermission = await _requestStoragePermission();
        if(storagePermission) {
          FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
          if(result != null) {
            setState(() {
              _image = File(result.files.first.path!);
            });
          }
        }
        else {
          print('Storage permission was not granted');
        }
      },
      child: Container(
        height: _deviceHeight * 0.18,
        width: _deviceHeight * 0.18,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_deviceHeight * 0.1),
          image: DecorationImage(
            image: imageProvider as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _registerForm() {
    return SizedBox(
      height: _deviceHeight * 0.25,
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _nameTextField(),
            _emailTextField(),
            _passwordTextField(),
          ],
        ),
      ),
    );
  }

  Widget _nameTextField() {
    return TextFormField(
      decoration: const InputDecoration(hintText: "Name"),
      onSaved: (value) {
        setState(() {
          _name = value;
        });
      },
      validator: (value) => value!.isNotEmpty ? null : "Please enter a name",
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      decoration: const InputDecoration(hintText: "Email"),
      onSaved: (value) {
        setState(() {
          _email = value;
        });
      },
      validator: (value) {
        bool validEmail = value!.contains(RegExp(r'^[\w\.-]+@[a-zA-Z\d\.-]+\.[a-zA-Z]{2,}$'));
        return validEmail ? null : "Please enter a valid email";
      },
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      obscureText: true,
      decoration: const InputDecoration(hintText: "Password"),
      onSaved: (value) {
        setState(() {
          _password = value;
        });
      },
      validator: (value) => value!.length >= 8 ? null : "Password must have at least 8 characters",
    );
  }

  Widget _registerButtons() {
    return SizedBox(
      height: _deviceHeight * 0.09,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          _registerButton(),
          _loginPageLink(),
        ],
      ),
    );
  }

  Widget _registerButton() {
    return MaterialButton(
      onPressed: _registerUser,
      color: Colors.red,
      minWidth: _deviceWidth * 0.5,
      height: _deviceHeight * 0.05,
      child: const Text(
        "Register",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    );
  }

  void _registerUser() async {
    if(_registerFormKey.currentState!.validate() && _image != null) {
      _registerFormKey.currentState!.save();
      bool result = await _firebaseService!.registerUser(
        name: _name!,
        email: _email!,
        password: _password!,
        image: _image!
      );
      if(result && mounted) Navigator.popAndPushNamed(context, 'login');
    }
    else {
      print("All fields are required");
    }
  }

  Widget _loginPageLink() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: const Text(
        "I already have an account",
        style: TextStyle(
          color: Colors.blue,
          fontSize: 15,
        ),
      ),
    );
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