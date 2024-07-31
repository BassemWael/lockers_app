import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lockerapp/services/localization_services.dart';
import 'package:lockerapp/services/themeprovider.dart';
import 'package:provider/provider.dart';
import 'package:lockerapp/classes/locker.dart';
import 'package:lockerapp/services/apiservice.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _iDController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _nocController = TextEditingController();
  final TextEditingController _resMController = TextEditingController();
  final TextEditingController _IDController = TextEditingController();

  late Future<List<Locker>> _lockers;
  late Future<Locker> _locker;
  final ApiService apiService =
      ApiService("https://660c77a83a0766e85dbe299b.mockapi.io/api/v1");

  @override
  void initState() {
    super.initState();
    _lockers = apiService.getLockers();
  }

  @override
  void dispose() {
    _iDController.dispose();
    _locationController.dispose();
    _nocController.dispose();
    _resMController.dispose();
    _IDController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final inputWidth = screenWidth * 0.8;
    final inputwidthweb = screenWidth * 0.4;
    final themeProvider = Provider.of<ThemeProvider>(context);
    double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    double deviceWidthInPixels = screenWidth * devicePixelRatio;
    if (!kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                if (themeProvider.getTheme() == lightTheme) {
                  themeProvider.setTheme(darkTheme);
                } else {
                  themeProvider.setTheme(lightTheme);
                }
              },
              icon: Icon(
                themeProvider.getTheme() == lightTheme
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
            ),
            IconButton(
              onPressed: () {
                final localeService =
                    Provider.of<LocalizationServices>(context, listen: false);
                if (localeService.locale.languageCode == 'ar') {
                  localeService.changeLocale('en');
                } else {
                  localeService.changeLocale('ar');
                }
              },
              icon: Icon(Icons.language),
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.appTitle,
                style: TextStyle(fontSize: 32),
              ),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: inputWidth,
                      child: TextFormField(
                        controller: _iDController,
                        decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.lockerId),
                      ),
                    ),
                    SizedBox(
                      width: inputWidth,
                      child: TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.location),
                      ),
                    ),
                    SizedBox(
                      width: inputWidth,
                      child: TextFormField(
                        controller: _nocController,
                        decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context)!.numberOfCells),
                      ),
                    ),
                    SizedBox(
                      width: inputWidth,
                      child: TextFormField(
                        controller: _resMController,
                        decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context)!.reservationMode),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            int? lockerId = int.tryParse(_iDController.text);
                            int? numOfCells = int.tryParse(_nocController.text);
                            int? resMode;
                            if (_resMController.text.toLowerCase() ==
                                "shared") {
                              resMode = 1;
                            } else if (_resMController.text.toLowerCase() ==
                                "pre-assigned") {
                              resMode = 2;
                            } else {
                              resMode = 0;
                            }
                            int? id = int.tryParse(_IDController.text);

                            if (lockerId != null &&
                                numOfCells != null &&
                                resMode != null &&
                                id != null) {
                              apiService.updateLocker(
                                  id,
                                  Locker(
                                      lockerId: lockerId,
                                      location: _locationController.text,
                                      numOfCells: numOfCells,
                                      reservationMode: resMode,
                                      id: _IDController.text));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Please ensure all fields are filled correctly')),
                              );
                            }
                          },
                          child: Text(
                            AppLocalizations.of(context)!.saveLocker,
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            int id = int.tryParse(_IDController.text)!;
                            setState(() {
                              apiService.deleteLocker(id);
                            });
                          },
                          child: Text(
                            AppLocalizations.of(context)!.delete,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _lockers = apiService.getLockers();
                        });
                      },
                      child: Text(
                        AppLocalizations.of(context)!.scanNetwork,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: FutureBuilder<List<Locker>>(
                    future: _lockers,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No lockers available'));
                      } else {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            String? mode;
                            Locker locker = snapshot.data![index];
                            if (locker.reservationMode == 1) {
                              mode = "shared";
                            } else if (locker.reservationMode == 2) {
                              mode = "pre-assigned";
                            } else {
                              mode = "not provided";
                            }
                            return ListTile(
                              title: Text(
                                  '${AppLocalizations.of(context)!.lockerId} ${locker.lockerId}'),
                              subtitle: Text(
                                  '${AppLocalizations.of(context)!.location}: ${locker.location}'),
                              trailing: Column(
                                children: [
                                  Text(
                                      '${AppLocalizations.of(context)!.numberOfCells}: ${locker.numOfCells}'),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                      '${AppLocalizations.of(context)!.reservationMode}: $mode')
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  _iDController.text = "${locker.lockerId}";
                                  _locationController.text =
                                      "${locker.location}";
                                  _nocController.text = "${locker.numOfCells}";
                                  _resMController.text = mode as String;
                                  _IDController.text = locker.id as String;
                                });
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Show the dialog box
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(AppLocalizations.of(context)!.addLocker),
                  content: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.6,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: inputWidth,
                              child: TextFormField(
                                controller: _iDController,
                                decoration: InputDecoration(
                                    labelText:
                                        AppLocalizations.of(context)!.lockerId),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(
                              width: inputWidth,
                              child: TextFormField(
                                controller: _locationController,
                                decoration: InputDecoration(
                                    labelText:
                                        AppLocalizations.of(context)!.location),
                              ),
                            ),
                            SizedBox(
                              width: inputWidth,
                              child: TextFormField(
                                controller: _nocController,
                                decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)!
                                        .numberOfCells),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(
                              width: inputWidth,
                              child: TextFormField(
                                controller: _resMController,
                                decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)!
                                        .reservationMode),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(
                              width: inputWidth,
                              child: TextFormField(
                                controller: _IDController,
                                decoration: InputDecoration(
                                    labelText:
                                        AppLocalizations.of(context)!.iD),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () async {
                                bool isValid = true;
                                List<Locker> lockers =
                                    await apiService.getLockers();
                                for (var locker in lockers) {
                                  if (locker.lockerId ==
                                      int.tryParse(_iDController.text)) {
                                    isValid = false;
                                    break;
                                  }
                                }
                                if (isValid) {
                                  await apiService.addLocker(Locker(
                                    lockerId: int.tryParse(_iDController.text),
                                    location: _locationController.text,
                                    numOfCells:
                                        int.tryParse(_nocController.text),
                                    reservationMode:
                                        int.tryParse(_resMController.text),
                                    id: _IDController.text,
                                  ));
                                  Navigator.of(context)
                                      .pop(); // Close the dialog after adding
                                } else {
                                  // Show a message that locker ID is not unique
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            AppLocalizations.of(context)!
                                                .lockerIdNotUnique)),
                                  );
                                }
                              },
                              child:
                                  Text(AppLocalizations.of(context)!.addLocker),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text(AppLocalizations.of(context)!.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Icon(
            Icons.add,
          ),
        ),
      );
    } else {
      if (MediaQuery.of(context).size.width > 895) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () {
                  if (themeProvider.getTheme() == lightTheme) {
                    themeProvider.setTheme(darkTheme);
                  } else {
                    themeProvider.setTheme(lightTheme);
                  }
                },
                icon: Icon(
                  themeProvider.getTheme() == lightTheme
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
              ),
              IconButton(
                onPressed: () {
                  final localeService =
                      Provider.of<LocalizationServices>(context, listen: false);
                  if (localeService.locale.languageCode == 'ar') {
                    localeService.changeLocale('en');
                  } else {
                    localeService.changeLocale('ar');
                  }
                },
                icon: Icon(Icons.language),
              ),
            ],
          ),
          body: Center(
              child: Column(children: [
            Text(
              AppLocalizations.of(context)!.appTitle,
              style: TextStyle(fontSize: 32),
            ),
            Row(
              children: [
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: inputwidthweb,
                          child: TextFormField(
                            controller: _iDController,
                            decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.lockerId),
                          ),
                        ),
                        SizedBox(
                          width: inputwidthweb,
                          child: TextFormField(
                            controller: _locationController,
                            decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.location),
                          ),
                        ),
                        SizedBox(
                          width: inputwidthweb,
                          child: TextFormField(
                            controller: _nocController,
                            decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!
                                    .numberOfCells),
                          ),
                        ),
                        SizedBox(
                          width: inputwidthweb,
                          child: TextFormField(
                            controller: _resMController,
                            decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!
                                    .reservationMode),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        int? lockerId = int.tryParse(_iDController.text);
                        int? numOfCells = int.tryParse(_nocController.text);
                        int? resMode;
                        if (_resMController.text.toLowerCase() == "shared") {
                          resMode = 1;
                        } else if (_resMController.text.toLowerCase() ==
                            "pre-assigned") {
                          resMode = 2;
                        } else {
                          resMode = 0;
                        }
                        int? id = int.tryParse(_IDController.text);

                        if (lockerId != null &&
                            numOfCells != null &&
                            resMode != null &&
                            id != null) {
                          apiService.updateLocker(
                              id,
                              Locker(
                                  lockerId: lockerId,
                                  location: _locationController.text,
                                  numOfCells: numOfCells,
                                  reservationMode: resMode,
                                  id: _IDController.text));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Please ensure all fields are filled correctly')),
                          );
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.saveLocker,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        int id = int.tryParse(_IDController.text)!;
                        setState(() {
                          apiService.deleteLocker(id);
                        });
                      },
                      child: Text(
                        AppLocalizations.of(context)!.delete,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _lockers = apiService.getLockers();
                        });
                      },
                      child: Text(
                        AppLocalizations.of(context)!.scanNetwork,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SizedBox(
                    width: inputwidthweb,
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: FutureBuilder<List<Locker>>(
                      future: _lockers,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('No lockers available'));
                        } else {
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              String? mode;
                              Locker locker = snapshot.data![index];
                              if (locker.reservationMode == 1) {
                                mode = "shared";
                              } else if (locker.reservationMode == 2) {
                                mode = "pre-assigned";
                              } else {
                                mode = "not provided";
                              }
                              return ListTile(
                                title: Text(
                                    '${AppLocalizations.of(context)!.lockerId} ${locker.lockerId}'),
                                subtitle: Text(
                                    '${AppLocalizations.of(context)!.location}: ${locker.location}'),
                                trailing: Column(
                                  children: [
                                    Text(
                                        '${AppLocalizations.of(context)!.numberOfCells}: ${locker.numOfCells}'),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                        '${AppLocalizations.of(context)!.reservationMode}: $mode')
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    _iDController.text = "${locker.lockerId}";
                                    _locationController.text =
                                        "${locker.location}";
                                    _nocController.text =
                                        "${locker.numOfCells}";
                                    _resMController.text = mode as String;
                                    _IDController.text = locker.id as String;
                                  });
                                },
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            )
          ])),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Show the dialog box
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.addLocker),
                    content: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.6,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: inputWidth,
                                child: TextFormField(
                                  controller: _iDController,
                                  decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!
                                          .lockerId),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(
                                width: inputWidth,
                                child: TextFormField(
                                  controller: _locationController,
                                  decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!
                                          .location),
                                ),
                              ),
                              SizedBox(
                                width: inputWidth,
                                child: TextFormField(
                                  controller: _nocController,
                                  decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!
                                          .numberOfCells),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(
                                width: inputWidth,
                                child: TextFormField(
                                  controller: _resMController,
                                  decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!
                                          .reservationMode),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(
                                width: inputWidth,
                                child: TextFormField(
                                  controller: _IDController,
                                  decoration: InputDecoration(
                                      labelText:
                                          AppLocalizations.of(context)!.iD),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () async {
                                  bool isValid = true;
                                  List<Locker> lockers =
                                      await apiService.getLockers();
                                  for (var locker in lockers) {
                                    if (locker.lockerId ==
                                        int.tryParse(_iDController.text)) {
                                      isValid = false;
                                      break;
                                    }
                                  }
                                  if (isValid) {
                                    await apiService.addLocker(Locker(
                                      lockerId:
                                          int.tryParse(_iDController.text),
                                      location: _locationController.text,
                                      numOfCells:
                                          int.tryParse(_nocController.text),
                                      reservationMode:
                                          int.tryParse(_resMController.text),
                                      id: _IDController.text,
                                    ));
                                    Navigator.of(context)
                                        .pop(); // Close the dialog after adding
                                  } else {
                                    // Show a message that locker ID is not unique
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              AppLocalizations.of(context)!
                                                  .lockerIdNotUnique)),
                                    );
                                  }
                                },
                                child: Text(
                                    AppLocalizations.of(context)!.addLocker),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text(AppLocalizations.of(context)!.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Icon(
              Icons.add,
            ),
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () {
                  if (themeProvider.getTheme() == lightTheme) {
                    themeProvider.setTheme(darkTheme);
                  } else {
                    themeProvider.setTheme(lightTheme);
                  }
                },
                icon: Icon(
                  themeProvider.getTheme() == lightTheme
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
              ),
              IconButton(
                onPressed: () {
                  final localeService =
                      Provider.of<LocalizationServices>(context, listen: false);
                  if (localeService.locale.languageCode == 'ar') {
                    localeService.changeLocale('en');
                  } else {
                    localeService.changeLocale('ar');
                  }
                },
                icon: Icon(Icons.language),
              ),
            ],
          ),
          body: Center(
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.appTitle,
                  style: TextStyle(fontSize: 32),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: inputWidth,
                        child: TextFormField(
                          controller: _iDController,
                          decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!.lockerId),
                        ),
                      ),
                      SizedBox(
                        width: inputWidth,
                        child: TextFormField(
                          controller: _locationController,
                          decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!.location),
                        ),
                      ),
                      SizedBox(
                        width: inputWidth,
                        child: TextFormField(
                          controller: _nocController,
                          decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!.numberOfCells),
                        ),
                      ),
                      SizedBox(
                        width: inputWidth,
                        child: TextFormField(
                          controller: _resMController,
                          decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!
                                  .reservationMode),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              int? lockerId = int.tryParse(_iDController.text);
                              int? numOfCells =
                                  int.tryParse(_nocController.text);
                              int? resMode;
                              if (_resMController.text.toLowerCase() ==
                                  "shared") {
                                resMode = 1;
                              } else if (_resMController.text.toLowerCase() ==
                                  "pre-assigned") {
                                resMode = 2;
                              } else {
                                resMode = 0;
                              }
                              int? id = int.tryParse(_IDController.text);

                              if (lockerId != null &&
                                  numOfCells != null &&
                                  resMode != null &&
                                  id != null) {
                                apiService.updateLocker(
                                    id,
                                    Locker(
                                        lockerId: lockerId,
                                        location: _locationController.text,
                                        numOfCells: numOfCells,
                                        reservationMode: resMode,
                                        id: _IDController.text));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Please ensure all fields are filled correctly')),
                                );
                              }
                            },
                            child: Text(
                              AppLocalizations.of(context)!.saveLocker,
                            ),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {
                              int id = int.tryParse(_IDController.text)!;
                              setState(() {
                                apiService.deleteLocker(id);
                              });
                            },
                            child: Text(
                              AppLocalizations.of(context)!.delete,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _lockers = apiService.getLockers();
                          });
                        },
                        child: Text(
                          AppLocalizations.of(context)!.scanNetwork,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FutureBuilder<List<Locker>>(
                      future: _lockers,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('No lockers available'));
                        } else {
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              String? mode;
                              Locker locker = snapshot.data![index];
                              if (locker.reservationMode == 1) {
                                mode = "shared";
                              } else if (locker.reservationMode == 2) {
                                mode = "pre-assigned";
                              } else {
                                mode = "not provided";
                              }
                              return ListTile(
                                title: Text(
                                    '${AppLocalizations.of(context)!.lockerId} ${locker.lockerId}'),
                                subtitle: Text(
                                    '${AppLocalizations.of(context)!.location}: ${locker.location}'),
                                trailing: Column(
                                  children: [
                                    Text(
                                        '${AppLocalizations.of(context)!.numberOfCells}: ${locker.numOfCells}'),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                        '${AppLocalizations.of(context)!.reservationMode}: $mode')
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    _iDController.text = "${locker.lockerId}";
                                    _locationController.text =
                                        "${locker.location}";
                                    _nocController.text =
                                        "${locker.numOfCells}";
                                    _resMController.text = mode as String;
                                    _IDController.text = locker.id as String;
                                  });
                                },
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Show the dialog box
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.addLocker),
                    content: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.6,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: inputWidth,
                                child: TextFormField(
                                  controller: _iDController,
                                  decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!
                                          .lockerId),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(
                                width: inputWidth,
                                child: TextFormField(
                                  controller: _locationController,
                                  decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!
                                          .location),
                                ),
                              ),
                              SizedBox(
                                width: inputWidth,
                                child: TextFormField(
                                  controller: _nocController,
                                  decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!
                                          .numberOfCells),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(
                                width: inputWidth,
                                child: TextFormField(
                                  controller: _resMController,
                                  decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!
                                          .reservationMode),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(
                                width: inputWidth,
                                child: TextFormField(
                                  controller: _IDController,
                                  decoration: InputDecoration(
                                      labelText:
                                          AppLocalizations.of(context)!.iD),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () async {
                                  bool isValid = true;
                                  List<Locker> lockers =
                                      await apiService.getLockers();
                                  for (var locker in lockers) {
                                    if (locker.lockerId ==
                                        int.tryParse(_iDController.text)) {
                                      isValid = false;
                                      break;
                                    }
                                  }
                                  if (isValid) {
                                    await apiService.addLocker(Locker(
                                      lockerId:
                                          int.tryParse(_iDController.text),
                                      location: _locationController.text,
                                      numOfCells:
                                          int.tryParse(_nocController.text),
                                      reservationMode:
                                          int.tryParse(_resMController.text),
                                      id: _IDController.text,
                                    ));
                                    Navigator.of(context)
                                        .pop(); // Close the dialog after adding
                                  } else {
                                    // Show a message that locker ID is not unique
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              AppLocalizations.of(context)!
                                                  .lockerIdNotUnique)),
                                    );
                                  }
                                },
                                child: Text(
                                    AppLocalizations.of(context)!.addLocker),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text(AppLocalizations.of(context)!.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Icon(
              Icons.add,
            ),
          ),
        );
      }
    }
  }
}
