import 'package:cached_network_image/cached_network_image.dart';
import 'package:confide/api/apis.dart';
import 'package:confide/create_group/create_group.dart';
import 'package:confide/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

class AddMembersInGroup extends StatefulWidget {
  const AddMembersInGroup({Key? key}) : super(key: key);

  @override
  State<AddMembersInGroup> createState() => _AddMembersInGroupState();
}

class _AddMembersInGroupState extends State<AddMembersInGroup> {
  final TextEditingController _search = TextEditingController();
  List<Map<String, dynamic>> membersList = [];
  bool isLoading = false;
  Map<String, dynamic>? userMap;

  String? dpURL = APIs.user.photoURL;

  // bool isLoadButton = false;

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  void getCurrentUserDetails() async {
    await APIs.firestore
        .collection('users')
        .doc(APIs.user.uid)
        .get()
        .then((map) {
      setState(() {
        membersList.add({
          "name": map['name'],
          "email": map['email'],
          "id": map['id'],
          "isAdmin": true,
        });
      });
    });
  }

  void onSearch() async {
    setState(() {
      isLoading = true;
    });

    await APIs.firestore
        .collection('users')
        .where("email", isEqualTo: _search.text)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        setState(() {
          userMap = value.docs[0].data();
          isLoading = false;
        });
        print(userMap);
      } else {
        setState(() {
          isLoading = false;
          userMap = null; // Reset userMap if no user found
        });
        print("User not found");
      }
    });
  }

  void onResultTap() {
    bool isAlreadyExist = false;

    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['id'] == userMap!['id']) {
        isAlreadyExist = true;
      }
    }

    if (!isAlreadyExist) {
      setState(() {
        membersList.add({
          "name": userMap!['name'],
          "email": userMap!['email'],
          "id": userMap!['id'],
          "isAdmin": false,
        });

        userMap = null;
      });
    }
  }

  void onRemoveMembers(int index) {
    if (membersList[index]['id'] != APIs.user.uid) {
      setState(() {
        membersList.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe2e7ef),
      appBar: AppBar(
        backgroundColor: const Color(0xff0c2c63),
        centerTitle: true,
        title: const Text(
          "Add Members",
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView.builder(
                itemCount: membersList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(
                        horizontal: mq.width * .04, vertical: 4),
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      onTap: () => onRemoveMembers(index),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .3),
                        child: CachedNetworkImage(
                          width: mq.height * .055,
                          height: mq.height * .055,
                          imageUrl:
                              // "https://firebasestorage.googleapis.com/v0/b/confide-30fc8.appspot.com/o/profile_pictures%2Fss-modified.png?alt=media&token=8fb1ff37-b78e-4acb-b4b7-bf7d64398953",
                              "$dpURL",
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                            child: Icon(CupertinoIcons.person),
                          ),
                        ),
                      ),
                      title: Text(membersList[index]['name']),
                      subtitle: Text(membersList[index]['email']),
                      trailing: membersList[index]['id'] != APIs.user.uid
                          ? const Icon(
                              CupertinoIcons.clear_circled_solid,
                              color: Colors.red,
                            ) // If condition is true, hide the trailing icon
                          : const Icon(
                              CupertinoIcons.checkmark_alt_circle_fill,
                              color: Colors.green,
                            ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: mq.height / 20,
            ),
            Container(
              height: mq.height / 14,
              width: mq.width,
              alignment: Alignment.center,
              child: SizedBox(
                height: mq.height / 14,
                width: mq.width / 1.12,
                child: TextField(
                  controller: _search,
                  cursorColor: Colors.redAccent,
                  decoration: InputDecoration(
                    hintText: "Enter member email ID",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: "Search Member", // Added labelText
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
            isLoading
                ? Container(
                    height: mq.height / 12,
                    width: mq.height / 12,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  )
                :
                // ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //       textStyle: const TextStyle(fontSize: 12),
                //       minimumSize: const Size.fromHeight(24),
                //       shape: const StadiumBorder(),
                //     ),
                //     onPressed: () {
                //       setState(() {
                //         isLoadButton = true;
                //       });
                //       onSearch();
                //       isLoadButton = false;
                //     },
                //     child: isLoadButton
                //         ? const Row(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             children: [
                //               CircularProgressIndicator(
                //                   color: Colors.redAccent),
                //               SizedBox(
                //                 width: 12,
                //               ),
                //               Text('Please Wait...'),
                //             ],
                //           )
                //         : const Text("Search"),
                //   ),

                ProgressButton.icon(
                    onPressed: () async {
                      setState(() {
                        isLoading = true; // Set loading state
                      });

                      try {
                        final querySnapshot = await APIs.firestore
                            .collection('users')
                            .where("email", isEqualTo: _search.text)
                            .get();

                        if (querySnapshot.docs.isNotEmpty) {
                          setState(() {
                            userMap = querySnapshot.docs[0].data();
                            isLoading = false; // Reset loading state
                          });
                          print(userMap);
                        } else {
                          setState(() {
                            isLoading = false; // Reset loading state
                            userMap = null; // Reset userMap if no user found
                          });
                          print("User not found");
                        }
                      } catch (e) {
                        setState(() {
                          isLoading = false; // Reset loading state
                          userMap = null; // Reset userMap on error
                        });
                        print("Error: $e");
                      }
                    },
                    state: isLoading ? ButtonState.loading : ButtonState.idle,
                    iconedButtons: {
                      ButtonState.idle: const IconedButton(
                        text: "Search",
                        icon: Icon(CupertinoIcons.search, color: Colors.white),
                        color: Color(0xff0c2c63),
                      ),
                      ButtonState.loading: const IconedButton(
                        text: "Loading",
                        color: Color(0xff0c2c63),
                      ),
                      ButtonState.fail: IconedButton(
                        text: "Failed",
                        icon: const Icon(Icons.cancel, color: Colors.white),
                        color: Colors.red.shade300,
                      ),
                      ButtonState.success: IconedButton(
                        text: "Success",
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        ),
                        color: Colors.green.shade400,
                      ),
                    },
                  ),
            SizedBox(
              height: mq.height / 40,
            ),
            userMap != null
                ? Card(
                    margin: EdgeInsets.symmetric(
                        horizontal: mq.width * .04, vertical: 4),
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      onTap: onResultTap,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .3),
                        child: CachedNetworkImage(
                          width: mq.height * .055,
                          height: mq.height * .055,
                          imageUrl:
                              // "https://firebasestorage.googleapis.com/v0/b/confide-30fc8.appspot.com/o/profile_pictures%2Fss-modified.png?alt=media&token=8fb1ff37-b78e-4acb-b4b7-bf7d64398953",
                              "$dpURL",
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                            child: Icon(CupertinoIcons.person),
                          ),
                        ),
                      ),
                      title: Text(userMap!['name']),
                      subtitle: Text(userMap!['email']),
                      trailing: const Icon(
                        CupertinoIcons.add_circled_solid,
                        color: Color(0xff0c2c63),
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
      floatingActionButton: membersList.length >= 2
          ? Padding(
              padding: const EdgeInsets.only(bottom: 35, right: 15),
              child: FloatingActionButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateGroup(
                      membersList: membersList,
                    ),
                  ),
                ),
                backgroundColor: const Color(0xff0c2c63),
                child: const Icon(
                  CupertinoIcons.forward,
                  color: Colors.white,
                ),
              ),
            )
          : const SizedBox(),
    );
  }
}
