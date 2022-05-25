import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:passenger/constants/constants.dart';
import 'package:passenger/providers/providers.dart';
import 'package:passenger/models/models.dart';
// ignore: implementation_imports
import 'package:provider/src/provider.dart';

class TripForm extends StatefulWidget {
  final HomeProvider passedHomeProvider;
  final String passedCurrentUserId;

  const TripForm(
      {Key? key,
      required this.passedHomeProvider,
      required this.passedCurrentUserId})
      : super(key: key);

  @override
  State<TripForm> createState() => _TripFormState();
}

class _TripFormState extends State<TripForm> {
  final _formKey = GlobalKey<FormState>();
  late String currentUserId;
  late HomeProvider homeProvider;
  late SettingProvider settingProvider;

  DateTime? endDate;
  DateTime? startDate;
  bool _descriptionIsValid = true;
  bool isLoading = false;
  File? avatarImageFile;
  late String photoUrl;
  TextEditingController countryCtl = TextEditingController();
  TextEditingController locationCtl = TextEditingController();
  TextEditingController startDateCtl = TextEditingController();
  TextEditingController endDateCtl = TextEditingController();
  TextEditingController descriptionCtl = TextEditingController();

  @override
  initState() {
    settingProvider = context.read<SettingProvider>();
    photoUrl = '';
    currentUserId = widget.passedCurrentUserId;
    homeProvider = widget.passedHomeProvider;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile = await imagePicker
        // ignore: deprecated_member_use
        .getImage(source: ImageSource.gallery)
        .catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
    });
    File? image;
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }
    if (image != null) {
      setState(() {
        avatarImageFile = image;
      });
    }
    UploadTask uploadTask =
        settingProvider.uploadFile(avatarImageFile!, currentUserId);
    TaskSnapshot snapshot = await uploadTask;
    var downloadurl = await snapshot.ref.getDownloadURL();
    setState(() {
      isLoading = false;
      photoUrl = downloadurl;
    });
    return downloadurl;
  }

  Future _selectStartDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(
            DateTime.now().year + 1, DateTime.now().month, DateTime.now().day));
    if (picked != null) {
      setState(() {
        startDate = picked;
        startDateCtl.text = picked.toIso8601String();
      });
    }
  }

  Future _selectEndDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(
            DateTime.now().year + 1, DateTime.now().month, DateTime.now().day));
    if (picked != null) {
      setState(() {
        endDate = picked;
        endDateCtl.text = picked.toIso8601String();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create new Trip'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CupertinoButton(
                onPressed: getImage,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  child: avatarImageFile == null
                      ? photoUrl.isNotEmpty
                          ? Image.network(
                              photoUrl,
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
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: ColorConstants.themeColor,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
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
                            )
                          : const Icon(
                              Icons.image,
                              size: 90,
                              color: ColorConstants.greyColor,
                            )
                      : Image.file(
                          avatarImageFile!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                child: TextFormField(
                  validator: (country) {
                    if (country == null || country.isEmpty) {
                      return 'Please enter the country';
                    }
                    return null;
                  },
                  controller: countryCtl,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Country *'),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                child: TextFormField(
                  validator: (location) {
                    if (location == null || location.isEmpty) {
                      return 'Please enter the location';
                    }
                    return null;
                  },
                  controller: locationCtl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Location *',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                child: TextFormField(
                  validator: (startDate) {
                    if (startDate == null || startDate.isEmpty) {
                      return 'Please enter the start date';
                    }
                    return null;
                  },
                  controller: startDateCtl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Start Date *',
                  ),
                  onTap: () {
                    // Below line stops keyboard from appearing
                    FocusScope.of(context).requestFocus(FocusNode());

                    // Show Date Picker Here
                    _selectStartDate();
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                child: TextFormField(
                  validator: (endDate) {
                    if (endDate == null || endDate.isEmpty) {
                      return 'Please enter the end date';
                    }
                    return null;
                  },
                  controller: endDateCtl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'End Date *',
                  ),
                  onTap: () {
                    // Stops keyboard from appearing
                    FocusScope.of(context).requestFocus(FocusNode());

                    // Show DatePicker
                    _selectEndDate();
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: descriptionCtl,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Description *',
                    errorText: _descriptionIsValid
                        ? null
                        : 'Please enter the description',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.blue,
                    elevation: 5,
                  ),
                  child: const Text(
                    'Create Trip',
                    style:
                        TextStyle(color: Colors.white, fontFamily: 'SansBold'),
                  ),
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());

                    setState(() {
                      _descriptionIsValid = descriptionCtl.text.isNotEmpty;
                    });

                    if (_formKey.currentState!.validate() &&
                        _descriptionIsValid) {
                      homeProvider.addDataFirestore(
                          FirestoreConstants.pathTripCollection, {
                        FirestoreConstants.user: currentUserId,
                        FirestoreConstants.country: countryCtl.text,
                        FirestoreConstants.location: locationCtl.text,
                        FirestoreConstants.description: descriptionCtl.text,
                        FirestoreConstants.photoUrl:
                            photoUrl == null ? '' : photoUrl,
                        FirestoreConstants.creationDate: Timestamp.now(),
                        FirestoreConstants.startDate:
                            Timestamp.fromDate(startDate!),
                        FirestoreConstants.endDate:
                            Timestamp.fromDate(endDate!),
                      });
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Create Trip'),
                          content: Text(
                              "Trip '${countryCtl.text}, ${locationCtl.text}' was created successfully"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, 'Ok');
                              },
                              child: const Text('Ok'),
                            ),
                          ],
                        ),
                      );

                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TripFormEdit extends StatefulWidget {
  final HomeProvider passedHomeProvider;
  final String passedCurrentUserId;
  final Trip trip;
  final String photoUrl;
  const TripFormEdit(
      {Key? key,
      required this.passedHomeProvider,
      required this.passedCurrentUserId,
      required this.trip,
      required this.photoUrl})
      : super(key: key);

  @override
  State<TripFormEdit> createState() => _TripFormEditState();
}

class _TripFormEditState extends State<TripFormEdit> {
  final _formKey = GlobalKey<FormState>();
  late SettingProvider settingProvider;
  late String currentUserId;
  late HomeProvider homeProvider;
  late String photoUrl;
  TextEditingController countryCtl = TextEditingController();
  TextEditingController locationCtl = TextEditingController();
  TextEditingController startDateCtl = TextEditingController();
  TextEditingController endDateCtl = TextEditingController();
  TextEditingController descriptionCtl = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  bool _descriptionIsValid = true;
  bool isLoading = false;
  File? avatarImageFile;
  @override
  initState() {
    settingProvider = context.read<SettingProvider>();
    photoUrl = widget.photoUrl;
    currentUserId = widget.passedCurrentUserId;
    homeProvider = widget.passedHomeProvider;
    countryCtl.text = widget.trip.country;
    locationCtl.text = widget.trip.location;
    descriptionCtl.text = widget.trip.description;
    startDate = DateTime.fromMicrosecondsSinceEpoch(
        widget.trip.startDate.microsecondsSinceEpoch);
    startDateCtl.text = startDate?.toIso8601String() ?? '';
    endDate = DateTime.fromMicrosecondsSinceEpoch(
        widget.trip.endDate.microsecondsSinceEpoch);
    endDateCtl.text = endDate?.toIso8601String() ?? '';
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile = await imagePicker
        // ignore: deprecated_member_use
        .getImage(source: ImageSource.gallery)
        .catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
    });
    File? image;
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }
    if (image != null) {
      setState(() {
        avatarImageFile = image;
      });
    }
    UploadTask uploadTask =
        settingProvider.uploadFile(avatarImageFile!, currentUserId);
    TaskSnapshot snapshot = await uploadTask;
    var downloadurl = await snapshot.ref.getDownloadURL();
    setState(() {
      isLoading = false;
      photoUrl = downloadurl;
    });
    return downloadurl;
  }

  Future _selectStartDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(
            DateTime.now().year + 1, DateTime.now().month, DateTime.now().day));
    if (picked != null) {
      setState(() {
        startDate = picked;
        startDateCtl.text = picked.toIso8601String();
      });
    }
  }

  Future _selectEndDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(
            DateTime.now().year + 1, DateTime.now().month, DateTime.now().day));
    if (picked != null) {
      setState(() {
        endDate = picked;
        endDateCtl.text = picked.toIso8601String();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Trip'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CupertinoButton(
                onPressed: getImage,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  child: avatarImageFile == null
                      ? photoUrl.isNotEmpty
                          ? Image.network(
                              photoUrl,
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
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: ColorConstants.themeColor,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
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
                            )
                          : const Icon(
                              Icons.image,
                              size: 90,
                              color: ColorConstants.greyColor,
                            )
                      : Image.file(
                          avatarImageFile!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                child: TextFormField(
                  validator: (country) {
                    if (country == null || country.isEmpty) {
                      return 'Please enter the country';
                    }
                    return null;
                  },
                  controller: countryCtl,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Country *'),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                child: TextFormField(
                  validator: (location) {
                    if (location == null || location.isEmpty) {
                      return 'Please enter the location';
                    }
                    return null;
                  },
                  controller: locationCtl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Location *',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                child: TextFormField(
                  validator: (startDate) {
                    if (startDate == null || startDate.isEmpty) {
                      return 'Please enter the start date';
                    }
                    return null;
                  },
                  controller: startDateCtl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Start Date *',
                  ),
                  onTap: () {
                    // Below line stops keyboard from appearing
                    FocusScope.of(context).requestFocus(FocusNode());

                    // Show Date Picker Here
                    _selectStartDate();
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                child: TextFormField(
                  validator: (endDate) {
                    if (endDate == null || endDate.isEmpty) {
                      return 'Please enter the end date';
                    }
                    return null;
                  },
                  controller: endDateCtl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'End Date *',
                  ),
                  onTap: () {
                    // Below line stops keyboard from appearing
                    FocusScope.of(context).requestFocus(FocusNode());

                    // Show Date Picker Here
                    _selectEndDate();
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: descriptionCtl,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Description *',
                    errorText: _descriptionIsValid
                        ? null
                        : 'Please enter the description',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.blue,
                    elevation: 5,
                  ),
                  child: const Text(
                    'Edit Trip',
                    style:
                        TextStyle(color: Colors.white, fontFamily: 'SansBold'),
                  ),
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());

                    setState(() {
                      _descriptionIsValid = descriptionCtl.text.isNotEmpty;
                    });

                    if (_formKey.currentState!.validate() &&
                        _descriptionIsValid) {
                      homeProvider.updateDataFirestore(
                          FirestoreConstants.pathTripCollection,
                          widget.trip.id, {
                        FirestoreConstants.user: currentUserId,
                        FirestoreConstants.country: countryCtl.text,
                        FirestoreConstants.location: locationCtl.text,
                        FirestoreConstants.description: descriptionCtl.text,
                        FirestoreConstants.photoUrl: photoUrl,
                        FirestoreConstants.creationDate: Timestamp.now(),
                        FirestoreConstants.startDate:
                            Timestamp.fromDate(startDate!),
                        FirestoreConstants.endDate:
                            Timestamp.fromDate(endDate!),
                      });

                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Edit Trip'),
                          content: Text(
                              "Trip '${countryCtl.text}, ${locationCtl.text}' was edited successfully"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, 'Ok');
                              },
                              child: const Text('Ok'),
                            ),
                          ],
                        ),
                      );

                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
