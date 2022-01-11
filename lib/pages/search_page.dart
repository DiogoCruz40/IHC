import 'dart:async';
import 'dart:io';

import 'package:Passenger/pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:Passenger/constants/constants.dart';
import 'package:Passenger/providers/providers.dart';
import 'package:Passenger/utils/utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../widgets/widgets.dart';
import 'pages.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ScrollController listScrollController = ScrollController();
  int _limit = 20;
  final int _limitIncrement = 20;
  String _textSearch = "";
  bool isLoading = false;

  late SearchProvider searchProvider;
  Debouncer searchDebouncer = Debouncer(milliseconds: 300);

  final StreamController<bool> btnClearController =
      StreamController<bool>.broadcast();
  TextEditingController searchBarTec = TextEditingController();
  @override
  void initState() {
    super.initState();

    searchProvider = context.read<SearchProvider>();

    listScrollController.addListener(scrollListener);
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

  @override
  void dispose() {
    super.dispose();
    btnClearController.close();
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
                hintText: 'Search for location',
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
      Trip trip = Trip.fromDocument(document);

      return Container(
        child: TextButton(
          child: Row(
            children: <Widget>[
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Localização: ${trip.location}',
                          maxLines: 1,
                          style: const TextStyle(
                              color: ColorConstants.primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                      ),
                      Container(
                        child: Text(
                          'Descrição: ${trip.description}',
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
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => ChatPage(
            //       peerId: userChat.id,
            //       peerAvatar: userChat.photoUrl,
            //       peerNickname: userChat.nickname,
            //     ),
            //   ),
            // );
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
          child: StreamBuilder<QuerySnapshot>(
            stream: searchProvider.getStreamFireStore(
                FirestoreConstants.pathTripCollection, _limit, _textSearch),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                if ((snapshot.data?.docs.length ?? 0) > 0) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemBuilder: (context, index) =>
                        buildItem(context, snapshot.data?.docs[index]),
                    itemCount: snapshot.data?.docs.length,
                    controller: listScrollController,
                  );
                } else {
                  return const Center(
                    child: Text("No Trips"),
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    color: ColorConstants.themeColor,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
