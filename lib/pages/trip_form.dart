import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  bool _descriptionValidate = false;

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
                      errorText: _descriptionValidate
                          ? 'Please enter the description'
                          : null,
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
                        descriptionCtl.text.isEmpty
                            ? _descriptionValidate = true
                            : _descriptionValidate = false;
                      });

                      homeProvider.addTrip(Trip(
                        id: '',
                        user: currentUserId,
                        country: countryCtl.text,
                        location: locationCtl.text,
                        description: descriptionCtl.text,
                        creationDate: Timestamp.now(),
                        startDate: Timestamp.fromDate(startDate!),
                        endDate: Timestamp.fromDate(endDate!),
                      ));

                      if (_formKey.currentState!.validate()) {
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
