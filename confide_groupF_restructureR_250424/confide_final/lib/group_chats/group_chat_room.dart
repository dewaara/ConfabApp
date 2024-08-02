import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confide/api/apis.dart';
import 'package:confide/group_chats/group_info.dart';
import 'package:confide/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GroupChatRoom extends StatelessWidget {
  final String groupChatId, groupName;
  GroupChatRoom({Key? key, required this.groupChatId, required this.groupName})
      : super(key: key);

  final TextEditingController _message = TextEditingController();

  get context => null;

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "sendBy": APIs.user.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();

      await APIs.firestore
          .collection('groups')
          .doc(groupChatId)
          .collection('chats')
          .add(chatData);
    }
  }

  // bottom attach document
  List<Map<String, dynamic>> media = [];
  bool isRecording = false;

  // final record = Record();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe2e7ef),
      appBar: AppBar(
        backgroundColor: const Color(0xff0c2c63),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          groupName,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GroupInfo(
                  groupName: groupName,
                  groupId: groupChatId,
                ),
              ),
            ),
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: mq.height / 1.27,
                    width: mq.width,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: APIs.firestore
                          .collection('groups')
                          .doc(groupChatId)
                          .collection('chats')
                          .orderBy('time')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            reverse: false,
                            padding: EdgeInsets.only(top: mq.height * .01),
                            physics: const BouncingScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> chatMap =
                                  snapshot.data!.docs[index].data()
                                      as Map<String, dynamic>;

                              return messageTile(mq, chatMap);
                            },
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          _chatInput(),
        ],
      ),
    );
  }

  Widget messageTile(Size size, Map<String, dynamic> chatMap) {
    return Builder(builder: (_) {
      if (chatMap['type'] == "text") {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (chatMap['sendBy'] == APIs.user.displayName)
              Row(
                children: [
                  SizedBox(width: mq.width * .04),
                  const SizedBox(width: 2),
                  const Text(
                    '07:50 PM',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            Flexible(
              child: Container(
                width: size.width,
                alignment: chatMap['sendBy'] == APIs.user.displayName
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  decoration: BoxDecoration(
                    color: chatMap['sendBy'] == APIs.user.displayName
                        ? const Color.fromARGB(255, 218, 255, 176)
                        : const Color.fromARGB(255, 221, 245, 255),
                    border: chatMap['sendBy'] == APIs.user.displayName
                        ? Border.all(color: Colors.lightGreen)
                        : Border.all(color: Colors.lightBlue),
                    borderRadius: chatMap['sendBy'] == APIs.user.displayName
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                            bottomLeft: Radius.circular(30),
                          )
                        : const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        chatMap['sendBy'],
                        style: const TextStyle(
                            fontSize: 12, color: Colors.redAccent),
                      ),
                      const SizedBox(height: 4), // Adjust the spacing as needed
                      Text(
                        chatMap['message'],
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (chatMap['sendBy'] != APIs.user.displayName)
              Padding(
                padding: EdgeInsets.only(right: mq.width * .04),
                child: const Text(
                  '10:30 AM',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
          ],
        );
      } else if (chatMap['type'] == "img") {
        return Container(
          width: size.width,
          alignment: chatMap['sendBy'] == APIs.user.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            height: size.height / 2,
            child: Image.network(
              chatMap['message'],
            ),
          ),
        );
      } else if (chatMap['type'] == "notify") {
        return Container(
          width: size.width,
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black38,
            ),
            child: Text(
              chatMap['message'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      } else {
        return const SizedBox();
      }
    });
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // FocusScope.of(context).unfocus();
                      // setState(() => _showEmoji = !_showEmoji);
                    },
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Color(0xff0c2c63),
                      size: 25,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _message,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () {
                        // if (_showEmoji)
                        //   setState(() => _showEmoji = !_showEmoji);
                      },
                      decoration: const InputDecoration(
                          hintText: 'Type Something..',
                          hintStyle: TextStyle(color: Colors.blueAccent),
                          border: InputBorder.none),
                    ),
                  ),

                  // attach documents start

                  IconButton(
                    onPressed: () async {
                      await showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                                builder: (context, setState) {
                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  children: [
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text("Upload"),
                                        SizedBox(width: 10),
                                        Text("Cancel")
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      height: 120,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.grey[350]),
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: media.length,
                                        itemBuilder: (context, index) {
                                          return attachmentWidget(media[index],
                                              (int index) {
                                            setState(() {
                                              media.removeAt(index);
                                            });
                                          }, index);
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Wrap(
                                      children: [
                                        iconTextButton(
                                            "Photos", Colors.pinkAccent,
                                            () async {
                                          final images = await ImagePicker()
                                              .pickMultiImage(imageQuality: 70);

                                          // testing for select multiple images send but only two images are send so, in future resolve it..
                                          /*  for (var i in images){
                                          setState(() => _isUploading = true);
                                          await APIs.sendChatImage(widget.user, File(i.path));
                                          setState(() => _isUploading = false);
                                          Navigator.pop(context);
                                        }*/

                                          for (var i = 0;
                                              i < images.length;
                                              i++) {
                                            File file = File(images[i].path);
                                            setState(() async {
                                              media.add({
                                                "type": "image",
                                                "file": file
                                              });
                                            });
                                          }
                                                                                },
                                            const Icon(Icons.photo,
                                                color: Colors.white, size: 30),
                                            context),
                                        iconTextButton(
                                            "Video",
                                            Colors.blueGrey,
                                            () async {},
                                            const Icon(Icons.camera,
                                                color: Colors.white, size: 30),
                                            context),
                                        iconTextButton(
                                            "Audio",
                                            Colors.red,
                                            () {},
                                            const Icon(Icons.mic,
                                                color: Colors.white, size: 30),
                                            context),
                                        iconTextButton(
                                            "Document",
                                            Colors.blue,
                                            () {},
                                            const Icon(
                                                Icons.file_present_outlined,
                                                color: Colors.white,
                                                size: 30),
                                            context),
                                        iconTextButton(
                                            "Location",
                                            Colors.green,
                                            () {},
                                            const Icon(
                                                Icons.location_on_outlined,
                                                color: Colors.white,
                                                size: 30),
                                            context),
                                        iconTextButton(
                                            "Contact",
                                            Colors.teal,
                                            () {},
                                            const Icon(Icons.contact_page,
                                                color: Colors.white, size: 30),
                                            context),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            });
                          });
                    },
                    icon: const Icon(Icons.attach_file_rounded,
                        color: Colors.teal, size: 26),
                  ),
                  // attach documents start

                  IconButton(
                    onPressed: () async {
                      // final ImagePicker picker = ImagePicker();
                      // final XFile? image = await picker.pickImage(
                      //     source: ImageSource.camera, imageQuality: 70);
                      // if (image != null) {
                      //   log('Image paath: ${image.path}');
                      //   setState(() => _isUploading = true);
                      //   await APIs.sendChatImage(widget.user, File(image.path));
                      //   setState(() => _isUploading = false);
                      // }

                      // direct multiple images select and upload on chatting..
/*

                    final ImagePicker picker = ImagePicker();
                    final List<XFile> images =
                    await picker.pickMultiImage(imageQuality: 70);

                    for (var i in images) {
                      setState(() => _isUploading = true);
                      await APIs.sendChatImage(widget.user, File(i.path));
                      setState(() => _isUploading = false);
                    }

*/
                    },
                    icon: const Icon(Icons.camera_alt_rounded,
                        color: Color(0xff0c2c63), size: 26),
                  ),

                  SizedBox(width: mq.width * .02),
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: onSendMessage,
            minWidth: 0,
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
              right: 5,
              left: 10,
            ),
            shape: const CircleBorder(),
            color: Colors.green,
            child: const Icon(Icons.send, color: Colors.white, size: 28),
          )
        ],
      ),
    );
  }

  Widget iconTextButton(String name, Color color, Function function, Icon icon,
      BuildContext context) {
    return GestureDetector(
      onTap: () {
        function();
      },
      child: Container(
        width: mq.width * 0.3,
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
              child: icon,
            ),
            const SizedBox(height: 10),
            Text(name)
          ],
        ),
      ),
    );
  }

  Widget attachmentWidget(
      Map<String, dynamic> attachment, Function deleteAttachment, int index) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.white,
      margin: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          Align(
            child: Image.file(
              attachment["file"],
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
                onTap: () {
                  deleteAttachment(index);
                },
                child: const Icon(Icons.cancel)),
          ),
        ],
      ),
    );
  }
}
