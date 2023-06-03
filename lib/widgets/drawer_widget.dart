import 'package:circle_book/screens/group/g_member_manage_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:circle_book/screens/group/g_profile_screen.dart';

class Drawerwidget extends StatelessWidget {
  const Drawerwidget(
    this.groupid, {
    super.key,
  });

  final String groupid;

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('groups')
                .doc(groupid)
                .snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (snapshot.hasData) {
                  List<dynamic>? gm = snapshot.data!['groupMembers'];
                  String gl = snapshot.data!['groupLeader'];
                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .snapshots(),
                    builder:
                        (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return Column(
                          children: [
                            Expanded(
                              child: ListView(
                                padding: EdgeInsets.zero,
                                children: <Widget>[
                                  // 프로젝트에 assets 폴더 생성 후 이미지 2개 넣기
                                  // pubspec.yaml 파일에 assets 주석에 이미지 추가하기
                                  UserAccountsDrawerHeader(
                                    currentAccountPicture: const CircleAvatar(
                                      // 현재 계정 이미지 set
                                      backgroundImage: AssetImage(
                                          'assets/icons/usericon.png'),
                                      backgroundColor: Colors.white,
                                    ),
                                    otherAccountsPictures: const <Widget>[
                                      // CircleAvatar(
                                      //   backgroundColor: Colors.white,
                                      //   backgroundImage: AssetImage('assets/profile2.png'),
                                      // )
                                    ],
                                    accountName:
                                        Text(snapshot.data!['userName']),
                                    accountEmail:
                                        Text(snapshot.data!['userEmail']),
                                    /*
                            onDetailsPressed: () {
                              print('arrow is clicked');
                            },
                            */
                                    decoration: const BoxDecoration(
                                        color: Color(0xff6DC4DB),
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(40.0),
                                            bottomRight:
                                                Radius.circular(40.0))),
                                  ),
                                  SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        const Text("그룹 멤버"),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: gm?.length,
                                          itemBuilder: (context, index) {
                                            return StreamBuilder(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('users')
                                                    .doc(gm?[index])
                                                    .snapshots(),
                                                builder: (context,
                                                    AsyncSnapshot<
                                                            DocumentSnapshot>
                                                        snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  } else {
                                                    return ListTile(
                                                      leading: const CircleAvatar(
                                                          backgroundImage:
                                                              AssetImage(
                                                                  'assets/icons/usericon.png')),
                                                      title: Text(snapshot
                                                          .data!['userName']),
                                                      subtitle: Text(snapshot
                                                          .data!['userEmail']),
                                                      trailing: gl ==
                                                              snapshot.data![
                                                                  'userUID']
                                                          ? const Text('그룹장')
                                                          : const Text('그룹원'),
                                                      onTap: () {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    GroupProfilePage(
                                                                        snapshot
                                                                            .data!['userUID'])));
                                                      },
                                                    );
                                                  }
                                                });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Align(
                                      alignment: FractionalOffset.bottomCenter,
                                      child: Column(
                                        children: <Widget>[
                                          const Divider(),
                                          if (gl ==
                                              FirebaseAuth
                                                  .instance.currentUser?.uid)
                                            ListTile(
                                                leading: const Icon(
                                                    Icons.manage_accounts),
                                                title: const Text("그룹원 관리"),
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              GroupMemberManagePage(
                                                                  groupid)));
                                                }),
                                          ListTile(
                                            leading: const Icon(
                                                Icons.exit_to_app_sharp),
                                            title: const Text("그룹 나가기"),
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  barrierDismissible: true,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          "정말로 그룹을 탈퇴 하시겠습니까?"),
                                                      content:
                                                          const SingleChildScrollView(
                                                        child: ListBody(
                                                          children: <Widget>[
                                                            Text(
                                                                '그룹장 탈퇴시 자동으로 다른사람한테 그룹장이 이전됩니다.'),
                                                            Text(
                                                                '그룹장이 이전될 그룹원이 없을시, 그룹이 자동으로 해체됩니다.'),
                                                            Text(
                                                                '정말로 탈퇴를 원할시 확인 버튼 클릭하세요.'),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                            child: const Text(
                                                                '확인'),
                                                            onPressed:
                                                                () async {
                                                              DocumentSnapshot
                                                                  groupdata =
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'groups')
                                                                      .doc(
                                                                          groupid)
                                                                      .get();
                                                              int groupmemberscont =
                                                                  groupdata[
                                                                      'groupMembersCount'];
                                                              List<String>
                                                                  groupmemberlist =
                                                                  groupdata[
                                                                          'groupMembers']
                                                                      .cast<
                                                                          String>();
                                                              groupmemberlist.remove(
                                                                  FirebaseAuth
                                                                      .instance
                                                                      .currentUser
                                                                      ?.uid);
                                                              groupmemberscont -=
                                                                  1;
                                                              if (FirebaseAuth
                                                                      .instance
                                                                      .currentUser
                                                                      ?.uid ==
                                                                  groupdata[
                                                                      'groupLeader']) {
                                                                if (groupmemberscont ==
                                                                    0) {
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'groups')
                                                                      .doc(
                                                                          groupid)
                                                                      .delete();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                } else {
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'groups')
                                                                      .doc(
                                                                          groupid)
                                                                      .update({
                                                                    "groupLeader":
                                                                        groupmemberlist[
                                                                            0],
                                                                    "groupMembers":
                                                                        groupmemberlist,
                                                                    "groupMembersCount":
                                                                        groupmemberscont,
                                                                  });
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                }
                                                                /*
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                    '그룹장은 탈퇴가 불가능합니다.'),
                                                                backgroundColor:
                                                                    Colors.blue,
                                                              ),
                                                            );
                                                            */
                                                              } else {
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'groups')
                                                                    .doc(
                                                                        groupid)
                                                                    .update({
                                                                  "groupMembers":
                                                                      groupmemberlist,
                                                                  "groupMembersCount":
                                                                      groupmemberscont,
                                                                });
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              }
                                                            }),
                                                        TextButton(
                                                          child:
                                                              const Text('취소'),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  });
                                            },
                                          )
                                        ],
                                      )),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  );
                }
              }
              return const Center(
                child: Text('데이터를 불러올 수 없습니다.'),
              );
            }));
  }
}
