import 'package:confide/api/apis.dart';
import 'package:confide/auth/home_screen.dart';
import 'package:confide/create_group/admin_add_members.dart';
import 'package:confide/main.dart';
import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  final String groupId, groupName;
  const GroupInfo({required this.groupId, required this.groupName, Key? key})
      : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  List membersList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getGroupMembers();
  }

  void getGroupMembers() async {
    await APIs.firestore
        .collection('groups')
        .doc(widget.groupId)
        .get()
        .then((value) {
      setState(() {
        membersList = value['members'];
        print(membersList);
        isLoading = false;
      });
    });
  }

  bool checkAdmin() {
    bool isAdmin = false;

    for (var element in membersList) {
      if (element['id'] == APIs.user.uid) {
        isAdmin = element['isAdmin'];
      }
    }
    return isAdmin;
  }

  void removeMembers(int index) async {
    if (checkAdmin()) {
      if (APIs.user.uid != membersList[index]['id']) {
        setState(() {
          isLoading = true;
        });

        String uid = membersList[index]['id'];
        membersList.removeAt(index);

        await APIs.firestore.collection('groups').doc(widget.groupId).update({
          "members": membersList,
        }).then((value) async {
          await APIs.firestore
              .collection('users')
              .doc(uid)
              .collection('groups')
              .doc(widget.groupId)
              .delete();

          setState(() {
            isLoading = false;
          });
        });
      }
    } else {
      print("Can't remove");
    }
  }

  void showDialogBox(int index) {
    if (checkAdmin()) {
      if (APIs.user.uid != membersList[index]['id']) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: ListTile(
                  onTap: () => removeMembers(index),
                  title: const Text("Remove This Member"),
                ),
              );
            });
      }
    }
  }

  void onLeaveGroup() async {
    if (!checkAdmin()) {
      setState(() {
        isLoading = true;
      });

      for (int i = 0; i < membersList.length; i++) {
        if (membersList[i]['id'] == APIs.user.uid) {
          membersList.removeAt(i);
        }
      }

      await APIs.firestore.collection('groups').doc(widget.groupId).update({
        "members": membersList,
      });

      await APIs.firestore
          .collection('users')
          .doc(APIs.user.uid)
          .collection('groups')
          .doc(widget.groupId)
          .delete();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      print("Can't left group");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? Container(
                height: mq.height,
                width: mq.width,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: BackButton(),
                    ),
                    SizedBox(
                      height: mq.height / 8,
                      width: mq.width / 1.1,
                      child: Row(
                        children: [
                          Container(
                            height: mq.height / 11,
                            width: mq.height / 11,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: Icon(
                              Icons.group,
                              color: Colors.white,
                              size: mq.width / 10,
                            ),
                          ),
                          SizedBox(
                            width: mq.width / 20,
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                widget.groupName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: mq.width / 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //

                    SizedBox(
                      height: mq.height / 20,
                    ),

                    SizedBox(
                      width: mq.width / 1.1,
                      child: Text(
                        "${membersList.length} Members",
                        style: TextStyle(
                          fontSize: mq.width / 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: mq.height / 20,
                    ),

                    // Members Name

                    checkAdmin()
                        ? ListTile(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddMembersByAdmin(
                                  groupId: widget.groupId,
                                  groupName: widget.groupName,
                                  membersList: membersList,
                                ),
                              ),
                            ),
                            leading: const Icon(
                              Icons.add,
                            ),
                            title: Text(
                              "Add Members",
                              style: TextStyle(
                                fontSize: mq.width / 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : const SizedBox(),

                    Flexible(
                      child: ListView.builder(
                        itemCount: membersList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () => showDialogBox(index),
                            leading: const Icon(Icons.account_circle),
                            title: Text(
                              membersList[index]['name'],
                              style: TextStyle(
                                fontSize: mq.width / 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(membersList[index]['email']),
                            trailing: Text(
                                membersList[index]['isAdmin'] ? "Admin" : ""),
                          );
                        },
                      ),
                    ),

                    ListTile(
                      onTap: onLeaveGroup,
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                      ),
                      title: Text(
                        "Leave Group",
                        style: TextStyle(
                          fontSize: mq.width / 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
