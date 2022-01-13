import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:passenger/constants/constants.dart';
import 'package:passenger/providers/providers.dart';
import 'package:passenger/utils/utils.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import 'pages.dart';

class ViewTrip extends StatefulWidget {
  final String currentuserId;
  ViewTrip({Key? key, required this.currentuserId}) : super(key: key);

  @override
  _ViewTripState createState() => _ViewTripState();
}

class _ViewTripState extends State<ViewTrip> {
  final ScrollController listScrollController = ScrollController();
  int _limit = 20;
  final int _limitIncrement = 20;
  String _textSearch = "";
  bool isLoading = false;
  late SearchProvider searchProvider;
  Debouncer searchDebouncer = Debouncer(milliseconds: 300);
  late String currentuserId;
  final StreamController<bool> btnClearController =
      StreamController<bool>.broadcast();
  TextEditingController searchBarTec = TextEditingController();
  late String _teste;

  @override
  void initState() {
    currentuserId = widget.currentuserId;
    searchProvider = context.read<SearchProvider>();
    listScrollController.addListener(scrollListener);
    _teste = "init";
    super.initState();
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

  Widget buildItem(BuildContext context, int index, DocumentSnapshot? document,
      SearchProvider searchProvider) {
    if (document != null) {
      String locale = Localizations.localeOf(context).languageCode;
      initializeDateFormatting(locale, null);
      Trip trip = Trip.fromDocument(document);

      if (trip.user == currentuserId) {
        return const SizedBox.shrink();
      } else {
        return StreamBuilder<DocumentSnapshot>(
            stream: searchProvider.getFavourite(trip.id, currentuserId),
            builder: (BuildContext context2,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              return Container(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text('${trip.country}, ${trip.location}'),
                            subtitle: Row(children: [
                              Flexible(
                                  child: Column(
                                children: [
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          'Start Date: ${DateFormat.yMd(locale).format(trip.startDate.toDate())}')),
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          'End Date: ${DateFormat.yMd(locale).format(trip.endDate.toDate())}')),
                                ],
                              ))
                            ]),
                            leading: SizedBox(
                              width: 100,
                              child: Image.network(
                                trip.photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, object, stackTrace) {
                                  return const Icon(
                                    Icons.image,
                                    size: 50,
                                    color: ColorConstants.greyColor,
                                  );
                                },
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return SizedBox(
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: ColorConstants.themeColor,
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
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(snapshot.data?.exists == true
                                  ? Icons.star
                                  : Icons.star_border_outlined),
                              color: snapshot.data?.exists == true
                                  ? Colors.yellow
                                  : Colors.grey,
                              onPressed: () {
                                setState(() {
                                  if (snapshot.data?.exists == true) {
                                    searchProvider.removeFavourite(
                                        trip.id, currentuserId);
                                  } else {
                                    searchProvider.addFavourite(
                                        trip.id, currentuserId);
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.open_in_full_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                if (Utilities.isKeyboardShowing()) {
                                  Utilities.closeKeyboard(context);
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          TripDetails(document: document)),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                margin: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
              );
            });
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
          child: StreamBuilder<QuerySnapshot>(
            stream: searchProvider.getStreamFireStore(
                FirestoreConstants.pathTripCollection, _limit, _textSearch),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                if ((snapshot.data?.docs.length ?? 0) > 0) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemBuilder: (context, index) => buildItem(context, index,
                        snapshot.data?.docs[index], searchProvider),
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
