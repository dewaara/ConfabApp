import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:confide/auth/view_profile_screen.dart';
import 'package:confide/helper/my_date_util.dart';
import 'package:confide/modals/chat_user.dart';
import 'package:confide/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../api/apis.dart';
import '../main.dart';
import '../modals/message.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];
  final _textController = TextEditingController();
  bool _showEmoji = false, _isUploading = false;
  final int maxNameLength = 15;

  // bottom attach document
  List<Map<String, dynamic>> media = [];
  bool isRecording = false;

  // final record = Record();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() => _showEmoji = !_showEmoji);
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xffe2e7ef),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xff0c2c63),
              flexibleSpace: _appBar(),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                reverse: true,
                                itemCount: _list.length,
                                padding: EdgeInsets.only(top: mq.height * .01),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return MessageCard(message: _list[index]);
                                });
                          } else {
                            return const Center(
                              child: Text('Say Hey.. !! 🙋🏻',
                                  style: TextStyle(fontSize: 20)),
                            );
                          }
                      }
                    },
                  ),
                ),
                if (_isUploading)
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          child: CircularProgressIndicator(strokeWidth: 2))),
                _chatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      // config: Config(
                      //   bgColor: const Color.fromARGB(255, 234, 248, 255),
                      //   columns: 8,
                      //   emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      //   emojiViewConfig = const EmojiViewConfig(),
                      // ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewProfileScreen(user: widget.user),
          ),
        );
      },
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
          String displayName =
              list.isNotEmpty ? list[0].name : widget.user.name;
          if (displayName.length > maxNameLength) {
            displayName = '${displayName.substring(0, maxNameLength)}...';
          }

          return Expanded(
            // Wrap Row with Expanded
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .03),
                  child: CachedNetworkImage(
                    width: mq.height * .05,
                    height: mq.height * .05,
                    imageUrl:
                        list.isNotEmpty ? list[0].image : widget.user.image,
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      list.isNotEmpty
                          ? list[0].isOnline
                              ? 'Online'
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: list[0].lastActive)
                          : MyDateUtil.getLastActiveTime(
                              context: context,
                              lastActive: widget.user.lastActive),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // Handle camera button tap
                  },
                  icon: const Icon(
                    CupertinoIcons.videocam_circle_fill,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Handle call button tap
                  },
                  icon: const Icon(
                    Icons.call,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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
                      FocusScope.of(context).unfocus();
                      setState(() => _showEmoji = !_showEmoji);
                    },
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Color(0xff0c2c63),
                      size: 25,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () {
                        if (_showEmoji) {
                          setState(() => _showEmoji = !_showEmoji);
                        }
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
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);
                      if (image != null) {
                        log('Image paath: ${image.path}');
                        setState(() => _isUploading = true);
                        await APIs.sendChatImage(widget.user, File(image.path));
                        setState(() => _isUploading = false);
                      }

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
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                if (_list.isEmpty) {
                  APIs.sendFirstMessage(
                      widget.user, _textController.text, Type.text);
                } else {
                  APIs.sendMessage(
                      widget.user, _textController.text, Type.text);
                }
                _textController.text = '';
              }
            },
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
