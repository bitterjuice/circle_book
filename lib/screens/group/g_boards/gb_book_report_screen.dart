import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookReportScreen extends StatefulWidget {
  final String groupId, bookReportId;

  const BookReportScreen({
    super.key,
    required this.groupId,
    required this.bookReportId,
  });

  @override
  State<BookReportScreen> createState() => _BookReportScreenState();
}

class _BookReportScreenState extends State<BookReportScreen> {
  String opinion = '';
  final TextEditingController _textEditingController = TextEditingController();

  Future<void> _addOpinion(String opinion) async {
    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('bookReports')
          .doc(widget.bookReportId)
          .collection('opinions')
          .add({
        'opinionTime': FieldValue.serverTimestamp(),
        'opinionContent': opinion,
        'opinionWriter': FirebaseAuth.instance.currentUser?.uid,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: const Color(0xff6DC4DB),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "독후감 공유",
          style: TextStyle(
            fontSize: 24,
            fontFamily: "Ssurround",
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .collection('bookReports')
            .doc(widget.bookReportId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final doc = snapshot.data!;
          String bookReportContent =
              doc['bookReportContent'].replaceAll('<br>', '\n');

          String bookReportWriter = doc['bookReportWriter'];

          return SingleChildScrollView(
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.87,
                padding: const EdgeInsets.only(top: 20, right: 30, left: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: const Color(0xff6DC4DB), width: 3),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    padding: const EdgeInsets.all(12.5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: const Color(0xff6DC4DB)),
                                    ),
                                    child: Image.asset(
                                      'assets/icons/아이콘_상태표시바용(512px).png',
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(bookReportWriter)
                                        .get(),
                                    builder: (context, userSnapshot) {
                                      if (userSnapshot.hasError) {
                                        return Text(
                                            'Error: ${userSnapshot.error}');
                                      }
                                      if (!userSnapshot.hasData) {
                                        return const SizedBox();
                                      }
                                      final userDoc = userSnapshot.data!;
                                      String userName = userDoc['userName'];

                                      return Text(
                                        userName,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontFamily: "Ssurround",
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 70,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    elevation: 5,
                                    padding: const EdgeInsets.all(5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    backgroundColor: const Color(0xff6DC4DB),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: 30,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "3",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "SsurroundAir",
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              bookReportContent,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: "SsurroundAir",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black, width: 1)),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: TextFormField(
                              maxLines: null,
                              controller: _textEditingController,
                              onChanged: (value) {
                                opinion = value.replaceAll('\n', '<br>');
                              },
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                hintText: '의견을 입력하세요.',
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          IconButton(
                            onPressed: () {
                              if (opinion.isEmpty) {
                                Future.delayed(Duration.zero, () {
                                  final scaffoldContext =
                                      ScaffoldMessenger.of(context);
                                  scaffoldContext.showSnackBar(
                                    const SnackBar(
                                      content: Text('내용을 입력하세요.'),
                                      backgroundColor: Color(0xff6DC4DB),
                                    ),
                                  );
                                });
                              } else {
                                _addOpinion(opinion);
                                _textEditingController.clear();
                                opinion = '';
                              }
                            },
                            icon: const Icon(
                              Icons.send,
                              color: Color(0xff6DC4DB),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      height: 2,
                      width: MediaQuery.of(context).size.width,
                      color: const Color(0xff6DC4DB),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              opinionListShow(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> opinionListShow() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('bookReports')
          .doc(widget.bookReportId)
          .collection('opinions')
          .orderBy('opinionTime', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          default:
            List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
            return Wrap(
              spacing: 0.0,
              runSpacing: 5.0,
              children: documents.map(
                (doc) {
                  String opinionContent =
                      doc['opinionContent'].replaceAll('<br>', '\n');
                  String opinionWriter = doc['opinionWriter'];
                  Timestamp? opinionTimestamp = doc['opinionTime'];
                  DateTime opinionTime = opinionTimestamp != null
                      ? opinionTimestamp.toDate()
                      : DateTime.now();
                  String formattedDate2 =
                      DateFormat('yyyy/MM/dd HH:mm').format(opinionTime);

                  return Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              padding: const EdgeInsets.all(7.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: const Color(0xff6DC4DB)),
                              ),
                              child: Image.asset(
                                'assets/icons/아이콘_상태표시바용(512px).png',
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(opinionWriter)
                                  .get(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.hasError) {
                                  return Text('Error: ${userSnapshot.error}');
                                }
                                if (!userSnapshot.hasData) {
                                  return const SizedBox();
                                }
                                final userDoc = userSnapshot.data!;
                                String userName = userDoc['userName'];

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontFamily: "Ssurround",
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      formattedDate2,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontFamily: "SsurroundAir",
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            opinionContent,
                            style: const TextStyle(
                              fontSize: 15,
                              fontFamily: "SsurroundAir",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ).toList(),
            );
        }
      },
    );
  }
}
