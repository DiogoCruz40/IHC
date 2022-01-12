import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:passenger/constants/constants.dart';
import 'package:passenger/providers/providers.dart';
import 'package:passenger/models/models.dart';

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

  @override
  initState() {
    currentUserId = widget.passedCurrentUserId;
    homeProvider = widget.passedHomeProvider;
    super.initState();
  }

  DateTime? endDate;
  DateTime? startDate;
  bool _descriptionIsValid = false;

  TextEditingController countryCtl = TextEditingController();
  TextEditingController locationCtl = TextEditingController();
  TextEditingController startDateCtl = TextEditingController();
  TextEditingController endDateCtl = TextEditingController();
  TextEditingController descriptionCtl = TextEditingController();

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
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Column(
              children: [
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
                      labelText: 'Location',
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
                      style: TextStyle(
                          color: Colors.white, fontFamily: 'SansBold'),
                    ),
                    onPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());

                      setState(() {
                        _descriptionIsValid = descriptionCtl.text.isNotEmpty;
                      });

                      homeProvider.addDataFirestore(
                          FirestoreConstants.pathTripCollection, {
                        FirestoreConstants.user: currentUserId,
                        FirestoreConstants.country: countryCtl.text,
                        FirestoreConstants.location: locationCtl.text,
                        FirestoreConstants.description: descriptionCtl.text,
                        FirestoreConstants.creationDate: Timestamp.now(),
                        FirestoreConstants.startDate:
                            Timestamp.fromDate(startDate!),
                        FirestoreConstants.endDate:
                            Timestamp.fromDate(endDate!),
                      });

                      if (_formKey.currentState!.validate() &&
                          _descriptionIsValid) {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Create Trip'),
                            content: Text(
                                'Trip "${countryCtl.text}, ${locationCtl.text}" was created successfully'),
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
      ),
    );
  }
}

class TripFormEdit extends StatefulWidget {
  final HomeProvider passedHomeProvider;
  final String passedCurrentUserId;
  final Trip trip;

  const TripFormEdit(
      {Key? key,
      required this.passedHomeProvider,
      required this.passedCurrentUserId,
      required this.trip})
      : super(key: key);

  @override
  State<TripFormEdit> createState() => _TripFormEditState();
}

class _TripFormEditState extends State<TripFormEdit> {
  final _formKey = GlobalKey<FormState>();
  late String currentUserId;
  late HomeProvider homeProvider;

  TextEditingController countryCtl = TextEditingController();
  TextEditingController locationCtl = TextEditingController();
  TextEditingController startDateCtl = TextEditingController();
  TextEditingController endDateCtl = TextEditingController();
  TextEditingController descriptionCtl = TextEditingController();

  DateTime? endDate;
  DateTime? startDate;
  bool _descriptionIsValid = false;

  @override
  initState() {
    currentUserId = widget.passedCurrentUserId;
    homeProvider = widget.passedHomeProvider;
    countryCtl.text = widget.trip.country;
    locationCtl.text = widget.trip.location;
    descriptionCtl.text = widget.trip.description;
    startDateCtl.text = DateTime.fromMicrosecondsSinceEpoch(
            widget.trip.startDate.microsecondsSinceEpoch)
        .toIso8601String();
    endDateCtl.text = DateTime.fromMicrosecondsSinceEpoch(
            widget.trip.endDate.microsecondsSinceEpoch)
        .toIso8601String();
    super.initState();
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
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Column(
              children: [
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
                      labelText: 'Location',
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
                      style: TextStyle(
                          color: Colors.white, fontFamily: 'SansBold'),
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
                                'Trip "${countryCtl.text}, ${locationCtl.text}" was edited successfully'),
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
      ),
    );
  }
}
