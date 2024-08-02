import 'package:confide/api/apis.dart';
import 'package:confide/auth/home_screen.dart';
import 'package:confide/main.dart';
import 'package:flutter/material.dart';

class AddMembersByAdmin extends StatefulWidget {
  final String groupId, groupName;
  final List membersList;
  const AddMembersByAdmin(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.membersList})
      : super(key: key);

  @override
  _AddMembersByAdminState createState() => _AddMembersByAdminState();
}

class _AddMembersByAdminState extends State<AddMembersByAdmin> {
  final TextEditingController _search = TextEditingController();
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  List membersList = [];

  @override
  void initState() {
    super.initState();
    membersList = widget.membersList;
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

  void onAddMembers() async {
    bool isAlreadyExist = false;

    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['id'] == userMap!['id']) {
        isAlreadyExist = true;
      }
    }

    // membersList.add({
    //   "name": userMap!['name'],
    //   "email": userMap!['email'],
    //   "id": userMap!['id'],
    //   "isAdmin": false,
    // });

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

    await APIs.firestore.collection('groups').doc(widget.groupId).update({
      "members": membersList,
    });

    await APIs.firestore
        .collection('users')
        .doc(APIs.user.uid)
        .collection('groups')
        .doc(widget.groupId)
        .set({
      "name": widget.groupName,
      "id": widget.groupId,
    });

    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(builder: (_) => HomeScreen()),
    //   (route) => false,
    // );
    Navigator.pop(context);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Members"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: mq.height / 20,
            ),
            Container(
              height: mq.height / 14,
              width: mq.width,
              alignment: Alignment.center,
              child: SizedBox(
                height: mq.height / 14,
                width: mq.width / 1.15,
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: "Search",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
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
                : ElevatedButton(
                    onPressed: onSearch,
                    child: const Text("Search"),
                  ),
            userMap != null
                ? ListTile(
                    onTap: onAddMembers,
                    leading: const Icon(Icons.account_box),
                    title: Text(userMap!['name']),
                    subtitle: Text(userMap!['email']),
                    trailing: const Icon(Icons.add),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
