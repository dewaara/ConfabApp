import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:confide/api/apis.dart';
import 'package:confide/auth/profile_screen.dart';
import 'package:confide/create_group/add_members.dart';
import 'package:confide/group_chats/group_chat_room.dart';
import 'package:confide/helper/dialogs.dart';
import 'package:confide/main.dart';
import 'package:confide/conference/conference_home_page.dart';
import 'package:confide/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../modals/chat_user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;
  List groupList = [];
  bool isLoading = true;

  String? groupsublinetxt = APIs.user.displayName;

  void getAvailableGroups() async {
    await APIs.firestore
        .collection('users')
        .doc(APIs.user.uid)
        .collection('groups')
        .get()
        .then((value) {
      setState(() {
        groupList = value.docs;
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    APIs.updateActiveStatus(true);
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
    getAvailableGroups();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // hiding keyboard when a tab is detected on screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        //if search in on & back button is press then close search
        // and else simple cloase current screen on back button click
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xffe2e7ef),
          appBar: AppBar(
            // leading: const Icon(CupertinoIcons.home),
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                        hintText: 'Name, Email,...'),
                    autofocus: true,
                    style: const TextStyle(
                        fontSize: 17,
                        letterSpacing: 0.5,
                        color: Color(0xffe2e7ef)),
                    onChanged: (val) {
                      _searchList.clear();
                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                : const Text(
                    'ConfideApp',
                    style: TextStyle(
                      color: Colors.white, // Set text color to red
                      fontSize: 20,
                    ),
                  ),
            backgroundColor: const Color(0xff0c2c63),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(
                  _isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfileScreen(user: APIs.me)));
                },
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 35, right: 15),
            child: SizedBox(
              width: 65,
              height: 65,
              child: SpeedDial(
                  icon: Icons.accessibility,
                  backgroundColor: const Color(0xff0c2c63),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  iconTheme: const IconThemeData(color: Colors.redAccent),
                  children: [
                    SpeedDialChild(
                      child: const Icon(CupertinoIcons.person,
                          color: Colors.white),
                      label: 'Add User',
                      labelBackgroundColor: Colors.green,
                      backgroundColor: Colors.green,
                      onTap: () {
                        _addChatUserDialog();
                      },
                    ),
                    SpeedDialChild(
                      child: const Icon(CupertinoIcons.group_solid,
                          color: Colors.white),
                      label: 'Create Group',
                      labelBackgroundColor: Colors.amber,
                      backgroundColor: Colors.amber,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddMembersInGroup(),
                        ),
                      ),
                    ),
                    SpeedDialChild(
                      child: const Icon(Icons.video_camera_back_rounded,
                          color: Colors.white),
                      label: 'Video Conference',
                      labelBackgroundColor: Colors.blue,
                      backgroundColor: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ConferenceHomePage()),
                        );
                      },
                    ),
                  ]),
            ),
          ),
          body: StreamBuilder(
            stream: APIs.getMyUsersId(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                case ConnectionState.active:
                case ConnectionState.done:
                  List<String> userIds =
                      snapshot.data?.docs.map((e) => e.id).toList() ?? [];

                  if (userIds.isNotEmpty) {
                    return StreamBuilder(
                      stream: APIs.getAllUsers(userIds),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          case ConnectionState.none:
                            return const Text('No data');
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            _list = data
                                    ?.map((e) => ChatUser.fromJson(e.data()))
                                    .toList() ??
                                [];

                            if (_list.isNotEmpty) {
                              return SingleChildScrollView(
                                child: Column(
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: _isSearching
                                          ? _searchList.length
                                          : _list.length,
                                      padding:
                                          EdgeInsets.only(top: mq.height * .01),
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final user = _isSearching
                                            ? _searchList[index]
                                            : _list[index];
                                        return GestureDetector(
                                          // Add a long-press callback
                                          onLongPress: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) {
                                                return AlertDialog(
                                                  title:
                                                      const Text('Remove User'),
                                                  content: Text(
                                                    'Do you want to remove ${user.name} from the list?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        // Remove user from the list
                                                        setState(() {
                                                          _list.remove(user);
                                                          if (_isSearching) {
                                                            _searchList
                                                                .remove(user);
                                                          }
                                                        });
                                                        Navigator.pop(context);
                                                      },
                                                      child:
                                                          const Text('Remove'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: ChatUserCard(
                                            user: user,
                                          ),
                                        );
                                      },
                                    ),
                                    isLoading
                                        ? Container(
                                            height: mq.height,
                                            width: mq.width,
                                            alignment: Alignment.center,
                                            child:
                                                const CircularProgressIndicator(),
                                          )
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: groupList.length,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              return Card(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: mq.width * .04,
                                                    vertical: 4),
                                                elevation: 0.5,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: ListTile(
                                                  onTap: () =>
                                                      Navigator.of(context)
                                                          .push(
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          GroupChatRoom(
                                                        groupName:
                                                            groupList[index]
                                                                ['name'],
                                                        groupChatId:
                                                            groupList[index]
                                                                ['id'],
                                                      ),
                                                    ),
                                                  ),
                                                  leading: InkWell(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (_) =>
                                                            // ProfileDialog(
                                                            //     user: widget
                                                            //         .user),
                                                            const HomeScreen(),
                                                      );
                                                    },
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              mq.height * .3),
                                                      child: CachedNetworkImage(
                                                        width: mq.height * .055,
                                                        height:
                                                            mq.height * .055,
                                                        imageUrl:
                                                            "https://firebasestorage.googleapis.com/v0/b/confide-30fc8.appspot.com/o/profile_pictures%2Fss-modified.png?alt=media&token=8fb1ff37-b78e-4acb-b4b7-bf7d64398953",
                                                        placeholder: (context,
                                                                url) =>
                                                            const CircularProgressIndicator(),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            const CircleAvatar(
                                                          child: Icon(
                                                              CupertinoIcons
                                                                  .group_solid),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  title: Text(
                                                    groupList[index]['name']
                                                                .length >
                                                            20
                                                        ? groupList[index]
                                                                    ['name']
                                                                .substring(
                                                                    0, 20) +
                                                            '...'
                                                        : groupList[index]
                                                            ['name'],
                                                  ),
                                                  //last message show on user home screen
                                                  subtitle: Text(
                                                    // _message != null
                                                    //     ? _message!.type ==
                                                    //             Type.image
                                                    //         ? 'image'
                                                    //         : MyEnDe.de(
                                                    //             _message!.msg)
                                                    //     : widget.user.about,
                                                    // groupList[index]['id'],
                                                    groupsublinetxt!,
                                                    maxLines: 1,
                                                  ),
                                                  trailing: Container(
                                                    width: 20.5,
                                                    height: 20.5,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: const Icon(
                                                      CupertinoIcons
                                                          .group_solid,
                                                      color: Color(0xff0c2c63),
                                                      size:
                                                          20.5, // Adjust the size as needed
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                  ],
                                ),
                              );
                            } else {
                              return const Center(
                                child: Text(
                                  'No Connection Found!',
                                  style: TextStyle(fontSize: 20),
                                ),
                              );
                            }
                        }
                      },
                    );
                  } else {
                    // Handle case where userIds is empty
                    return const Center(
                      child: Text(
                        'No User IDs Found!',
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  }
              }
            },
          ),
        ),
      ),
    );
  }

  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Color(0xff0c2c63),
                    size: 25,
                  ),
                  Text(' Add User')
                ],
              ),
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Enter User Email',
                    prefixIcon:
                        const Icon(Icons.email, color: Color(0xff0c2c63)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (email.isNotEmpty) {
                      await APIs.addChatUser(email).then((value) {
                        if (!value) {
                          Dialogs.showSnackbar(context, 'User does not exist!');
                        }
                      });
                    }
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Color(0xff0c2c63), fontSize: 16),
                  ),
                ),
              ],
            ));
  }
}
