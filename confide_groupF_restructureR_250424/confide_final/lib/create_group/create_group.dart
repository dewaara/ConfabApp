import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:confide/api/apis.dart';
import 'package:confide/auth/home_screen.dart';
import 'package:confide/helper/dialogs.dart';
import 'package:confide/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class CreateGroup extends StatefulWidget {
  final List<Map<String, dynamic>> membersList;

  const CreateGroup({Key? key, required this.membersList}) : super(key: key);

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final TextEditingController _groupName = TextEditingController();
  bool isLoading = false;
  String? _image_group;
  String? dpURL = APIs.user.photoURL;

  void createGroup() async {
    String groupName = _groupName.text.trim();

    if (groupName.isEmpty) {
      Dialogs.showSnackbar(context, 'Please enter a group name');
    } else {
      setState(() {
        isLoading = true;
      });

      String groupId = const Uuid().v1();

      await APIs.firestore.collection('groups').doc(groupId).set({
        "members": widget.membersList,
        "id": groupId,
      });

      for (int i = 0; i < widget.membersList.length; i++) {
        String uid = widget.membersList[i]['id'];

        await APIs.firestore
            .collection('users')
            .doc(uid)
            .collection('groups')
            .doc(groupId)
            .set({
          "name": _groupName.text,
          "id": groupId,
        });
      }

      await APIs.firestore
          .collection('groups')
          .doc(groupId)
          .collection('chats')
          .add({
        "message": "${APIs.user.displayName} Created This Group.",
        "type": "notify",
      });

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false);
    }
    /////
  }

  // await _firestore.collection('groups').doc(groupId).collection('chats').add({
  //   "message": RichText(
  //     text: TextSpan(
  //       children: [
  //         TextSpan(
  //           text: "${_auth.currentUser!.displayName}",
  //           style: TextStyle(
  //             fontWeight: FontWeight.bold,
  //             color: Colors.red,
  //           ),
  //         ),
  //         TextSpan(
  //           text: " Created This Group.",
  //         ),
  //       ],
  //     ),
  //   ),
  //   "type": "notify",
  // });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe2e7ef),
      appBar: AppBar(
        backgroundColor: const Color(0xff0c2c63),
        centerTitle: true,
        title: const Text(
          "Group Name",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Container(
              height: mq.height,
              width: mq.width,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : Column(
              children: [
                SizedBox(
                  height: mq.height / 10,
                ),

////
                Stack(
                  children: [
                    _image_group != null
                        ?
                        // local image show on
                        ClipRRect(
                            borderRadius: BorderRadius.circular(mq.height * .1),
                            child: Image.file(
                              File(_image_group!),
                              width: mq.height * .16,
                              height: mq.height * .16,
                              fit: BoxFit.cover,
                            ))
                        :
                        // server image show
                        ClipRRect(
                            borderRadius: BorderRadius.circular(mq.height * .1),
                            child: CachedNetworkImage(
                              width: mq.height * .16,
                              height: mq.height * .16,
                              fit: BoxFit.cover,
                              imageUrl: "$dpURL",
                              errorWidget: (context, url, error) =>
                                  const CircleAvatar(
                                      child: Icon(CupertinoIcons.person)),
                            ),
                          ),
                    Positioned(
                      bottom: 0,
                      right: -15,
                      child: MaterialButton(
                        elevation: 1,
                        onPressed: () {
                          _showBottomSheet();
                        },
                        shape: const CircleBorder(),
                        color: Colors.redAccent,
                        child: const Icon(Icons.edit, color: Color(0xff0c2c63)),
                      ),
                    )
                  ],
                ),
                SizedBox(height: mq.height * .05),
////
                Container(
                  height: mq.height / 14,
                  width: mq.width,
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: mq.height / 14,
                    width: mq.width / 1.12,
                    child: TextField(
                      controller: _groupName,
                      cursorColor: Colors.redAccent,
                      decoration: InputDecoration(
                        hintText: "Enter Group name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: "Create Group", // Added labelText
                        fillColor: const Color(0xff0c2c63), // Added fillColor
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xff0c2c63),
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: mq.height / 50,
                ),
                ElevatedButton(
                  onPressed: createGroup,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xff0c2c63), // Text color
                  ),
                  child: const Text("Create Group"),
                ),
              ],
            ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
            children: [
              const Text('Pick Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              SizedBox(height: mq.height * .02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          log('ImagePAth: ${image.path} -- MimeType: ${image.mimeType}');
                          setState(() {
                            _image_group = image.path;
                          });
                          APIs.updateProfilePicture(File(_image_group!));
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('assets/gallery.png')),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          log('ImagePAth: ${image.path}');
                          setState(() {
                            _image_group = image.path;
                          });
                          APIs.updateProfilePicture(File(_image_group!));
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('assets/camera12.png')),
                ],
              )
            ],
          );
        });
  }
}
