import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:passenger/constants/constants.dart';
import 'package:passenger/providers/providers.dart';
import 'package:passenger/utils/utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../models/models.dart';
import '../widgets/widgets.dart';
import 'pages.dart';

class ChatsListPage extends StatefulWidget {
  String currentuserId;
  ChatsListPage({Key? key, required this.currentuserId}) : super(key: key);

  @override
  _ChatsListPageState createState() => _ChatsListPageState(this.currentuserId);
}

class _ChatsListPageState extends State<ChatsListPage> {
  final ScrollController listScrollController = ScrollController();
  int _limit = 20;
  final int _limitIncrement = 20;
  String _textSearch = "";
  bool isLoading = false;

  late HomeProvider homeProvider;
  Debouncer searchDebouncer = Debouncer(milliseconds: 300);

  final StreamController<bool> btnClearController =
      StreamController<bool>.broadcast();
  TextEditingController searchBarTec = TextEditingController();

  String currentuserId;

  _ChatsListPageState(this.currentuserId);

  @override
  void dispose() {
    super.dispose();
    btnClearController.close();
  }

  @override
  void initState() {
    super.initState();

    homeProvider = context.read<HomeProvider>();
  }

  void scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  Widget buildSearchBar() {
    return Container(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.search, color: ColorConstants.greyColor, size: 20),
          const SizedBox(width: 5),
          Expanded(
            child: TextFormField(
              textInputAction: TextInputAction.search,
              controller: searchBarTec,
              onChanged: (value) {
                searchDebouncer.run(() {
                  if (value.isNotEmpty) {
                    btnClearController.add(true);
                    setState(() {
                      _textSearch = value;
                    });
                  } else {
                    btnClearController.add(false);
                    setState(() {
                      _textSearch = "";
                    });
                  }
                });
              },
              decoration: const InputDecoration.collapsed(
                hintText: 'Search nickname',
                hintStyle:
                    TextStyle(fontSize: 13, color: ColorConstants.greyColor),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          StreamBuilder<bool>(
              stream: btnClearController.stream,
              builder: (context, snapshot) {
                return snapshot.data == true
                    ? GestureDetector(
                        onTap: () {
                          searchBarTec.clear();
                          btnClearController.add(false);
                          setState(() {
                            _textSearch = "";
                          });
                        },
                        child: const Icon(Icons.clear_rounded,
                            color: ColorConstants.greyColor, size: 20))
                    : const SizedBox.shrink();
              }),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: ColorConstants.greyColor2,
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 8),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot? document) {
    if (document != null) {
      UserChat userChat = UserChat.fromDocument(document);
      if (userChat.id == currentuserId) {
        return const SizedBox.shrink();
      } else {
        return Container(
          child: TextButton(
            child: Row(
              children: <Widget>[
                Material(
                  child: userChat.photoUrl.isNotEmpty
                      ? Image.network(
                          userChat.photoUrl,
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              width: 50,
                              height: 50,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: ColorConstants.themeColor,
                                  value: loadingProgress.expectedTotalBytes !=
                                              null &&
                                          loadingProgress.expectedTotalBytes !=
                                              null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, object, stackTrace) {
                            return const Icon(
                              Icons.account_circle,
                              size: 50,
                              color: ColorConstants.greyColor,
                            );
                          },
                        )
                      : const Icon(
                          Icons.account_circle,
                          size: 50,
                          color: ColorConstants.greyColor,
                        ),
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                  clipBehavior: Clip.hardEdge,
                ),
                Flexible(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text(
                            'Nickname: ${userChat.nickname}',
                            maxLines: 1,
                            style: const TextStyle(
                                color: ColorConstants.primaryColor),
                          ),
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                        ),
                        Container(
                          child: Text(
                            'About me: ${userChat.aboutMe}',
                            maxLines: 1,
                            style: const TextStyle(
                                color: ColorConstants.primaryColor),
                          ),
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        )
                      ],
                    ),
                    margin: const EdgeInsets.only(left: 20),
                  ),
                ),
              ],
            ),
            onPressed: () {
              if (Utilities.isKeyboardShowing()) {
                Utilities.closeKeyboard(context);
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    peerId: userChat.id,
                    peerAvatar: userChat.photoUrl,
                    peerNickname: userChat.nickname,
                  ),
                ),
              );
            },
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(ColorConstants.greyColor2),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
          margin: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildSearchBar(),
        Expanded(
          child: StreamBuilder(
              stream: homeProvider.getStreamMessagesFireStore(
                  FirestoreConstants.pathMessageCollection),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  if ((snapshot.data?.docs.length ?? 0) > 0) {
                    List peersmessages = List.empty(growable: true);
                    List idslist = List.empty(growable: true);
                    if (idslist.isNotEmpty || peersmessages.isNotEmpty) {
                      idslist.clear();
                      peersmessages.clear();
                    }
                    snapshot.data?.docs
                        .forEach((doc) => peersmessages.add(doc.id));

                    for (var i = 0; i < peersmessages.length; i++) {
                      if (peersmessages.elementAt(i).contains(currentuserId)) {
                        //print(docsids.elementAt(i));
                        if (peersmessages.elementAt(i).split("-").first ==
                            currentuserId) {
                          idslist.add(peersmessages
                              .elementAt(i)
                              .split("-")
                              .last
                              .toString());
                        } else {
                          idslist.add(peersmessages
                              .elementAt(i)
                              .split("-")
                              .first
                              .toString());
                        }
                      }
                    }

                    return StreamBuilder(
                        stream: homeProvider.getStreamUsersFireStore(
                            idslist,
                            FirestoreConstants.pathUserCollection,
                            currentuserId,
                            _textSearch),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (idslist.isNotEmpty || peersmessages.isNotEmpty) {
                            idslist.clear();
                            peersmessages.clear();
                          }
                          if (snapshot.hasData) {
                            if ((snapshot.data?.docs.length ?? 0) > 0) {
                              return ListView.builder(
                                padding: const EdgeInsets.all(10),
                                itemBuilder: (context, index) => buildItem(
                                    context, snapshot.data?.docs[index]),
                                itemCount: snapshot.data?.docs.length,
                                controller: listScrollController,
                              );
                            } else {
                              return const Center(
                                child: Text("No users"),
                              );
                            }
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: ColorConstants.themeColor,
                              ),
                            );
                          }
                        });
                  } else {
                    return const Center(
                      child: Text("No users"),
                    );
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: ColorConstants.themeColor,
                    ),
                  );
                }
                // return const Center(
                //   child: CircularProgressIndicator(
                //     color: ColorConstants.themeColor,
                //   ),
                // );
              }),
        ),
      ],
    );
  }
}
