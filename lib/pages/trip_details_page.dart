import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:passenger/utils/utils.dart';
import 'package:provider/provider.dart';

import 'package:passenger/constants/constants.dart';
import 'package:passenger/providers/providers.dart';

import '../models/models.dart';
import 'pages.dart';

class TripDetails extends StatefulWidget {
  final DocumentSnapshot? document;

  const TripDetails({Key? key, this.document}) : super(key: key);

  @override
  _TripDetailsState createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {
  final ScrollController listScrollController = ScrollController();

  bool isLoading = false;

  late SearchProvider searchProvider;
  Debouncer searchDebouncer = Debouncer(milliseconds: 300);
  late DocumentSnapshot? document;

  @override
  void initState() {
    super.initState();

    searchProvider = context.read<SearchProvider>();

    listScrollController.addListener(scrollListener);

    document = widget.document;
  }

  void scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Trip trip = Trip.fromDocument(document!);
    if (document != null) {
      String locale = Localizations.localeOf(context).languageCode;
      initializeDateFormatting(locale, null);
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Trip to ${trip.location}',
            overflow: TextOverflow.fade,
          ),
        ),
        body: Column(
          children: [
            Container(
              alignment: Alignment.center,
              child: CupertinoButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              FullPhotoPage(url: trip.photoUrl)));
                },
                child: Container(
                    margin: const EdgeInsets.all(10),
                    child: trip.photoUrl.isNotEmpty
                        ? Image.network(
                            trip.photoUrl,
                            fit: BoxFit.cover,
                            width: 200,
                            height: 200,
                            errorBuilder: (context, object, stackTrace) {
                              return const Icon(
                                Icons.image,
                                size: 100,
                                color: ColorConstants.greyColor,
                              );
                            },
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                width: 90,
                                height: 90,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: ColorConstants.themeColor,
                                    value: loadingProgress.expectedTotalBytes !=
                                                null &&
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          )
                        : const Icon(
                            Icons.image,
                            size: 100,
                            color: ColorConstants.greyColor,
                          )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black,
                                ),
                                children: [
                                  // TextSpan(
                                  //     text: 'De ',
                                  //     style: TextStyle(
                                  //         fontFamily: AppConstants.fontfamily)),
                                  TextSpan(
                                      text: DateFormat.yMd(locale)
                                          .format(trip.startDate.toDate())),
                                  const TextSpan(
                                    text: ' to ',
                                    style: TextStyle(
                                        fontFamily: AppConstants.fontfamily),
                                  ),
                                  TextSpan(
                                    text: DateFormat.yMd(locale)
                                        .format(trip.endDate.toDate()),
                                  ),
                                ])),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                            text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black,
                                ),
                                children: [
                              const TextSpan(
                                  text: 'Destination: ',
                                  style: TextStyle(
                                      fontFamily: AppConstants.fontfamily)),
                              TextSpan(
                                  text: '${trip.country}, ${trip.location}'),
                            ])),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                            text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black,
                                ),
                                children: [
                              const TextSpan(
                                  text: 'Description: ',
                                  style: TextStyle(
                                      fontFamily: AppConstants.fontfamily)),
                              TextSpan(text: trip.description),
                            ])),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  StreamBuilder(
                    stream: searchProvider.getUserFirestore(
                        FirestoreConstants.pathUserCollection, trip.user),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        UserChat userChat =
                            UserChat.fromDocument(snapshot.data);
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
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return SizedBox(
                                              width: 50,
                                              height: 50,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color:
                                                      ColorConstants.themeColor,
                                                  value: loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null &&
                                                          loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, object, stackTrace) {
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
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(25)),
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
                                                color: ColorConstants
                                                    .primaryColor),
                                          ),
                                          alignment: Alignment.centerLeft,
                                          margin: const EdgeInsets.fromLTRB(
                                              10, 0, 0, 5),
                                        ),
                                        Container(
                                          child: Text(
                                            'About me: ${userChat.aboutMe}',
                                            maxLines: 1,
                                            style: const TextStyle(
                                                color: ColorConstants
                                                    .primaryColor),
                                          ),
                                          alignment: Alignment.centerLeft,
                                          margin: const EdgeInsets.fromLTRB(
                                              10, 0, 0, 0),
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
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  ColorConstants.greyColor2),
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                            ),
                          ),
                          margin: const EdgeInsets.only(
                              bottom: 10, left: 5, right: 5),
                        );
                      } else {
                        return const Center(
                          child: Text("No user"),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      Fluttertoast.showToast(msg: "Something went wrong");
      Navigator.pop(context);
      return const SizedBox.shrink();
    }
  }
}
