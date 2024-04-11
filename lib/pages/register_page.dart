import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

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
  String? _name, _email, _password;
  File? _image;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.15),
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
    var imageProvider = _image != null ? FileImage(_image!) : const NetworkImage("https://i.pravatar.cc/300");
    //var imageProvider = _image != null ? FileImage(_image!) : const NetworkImage("https://as2.ftcdn.net/v2/jpg/03/49/49/79/1000_F_349497933_Ly4im8BDmHLaLzgyKg2f2yZOvJjBtlw5.jpg");

    return GestureDetector(
      onTap: () {
        FilePicker.platform.pickFiles(type: FileType.image).then((value) {
          setState(() {
            _image = File(value!.files.first.path!);
          });
        });
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

  void _registerUser() {
    if(_registerFormKey.currentState!.validate() && _image != null) {
      print("Form saved successfully");
      _registerFormKey.currentState!.save();
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
}