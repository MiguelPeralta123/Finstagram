import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finstagram/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfilePage> {
  FirebaseService? _firebaseService;
  late double _deviceHeight, _deviceWidth;

  @override
  void initState() {
    super.initState();
    _firebaseService = GetIt.instance.get<FirebaseService>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    
    return Container(
      height: _deviceHeight,
      width: _deviceWidth,
      padding: EdgeInsets.symmetric(
        horizontal: _deviceHeight * 0.01,
        vertical: _deviceWidth * 0.04,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _userInformation(),
          SizedBox(
            height: _deviceHeight * 0.05,
          ),
          _postsGridView(),
        ],
      ),
    );
  }

  Widget _userInformation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _userPicture(),
        SizedBox(
          width: _deviceWidth * 0.03,
        ),
        _userNameAndEmail(),
      ],
    );
  }

  Widget _userPicture() {
    return Container(
      height: _deviceHeight * 0.15,
      width: _deviceHeight * 0.15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_deviceHeight * 0.08),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(_firebaseService!.currentUser!['image'])
        ),
      ),
    );
  }

  Widget _userNameAndEmail() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _firebaseService!.currentUser!['name'],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          _firebaseService!.currentUser!['email'],
          style: const TextStyle(
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _postsGridView() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firebaseService!.getPostsByUser(),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            List posts = snapshot.data!.docs.map((e) => e.data()).toList();
            if(posts.isNotEmpty) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 3,
                  crossAxisSpacing: 3,
                ),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  Map post = posts[index];
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(post['image']),
                      ),
                    ),
                  );
                },
              );
            }
            else {
              return const Center(
                child: Text(
                  "No posts available",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 17,
                  ),
                ),
              );
            }
          }
          else {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }
}