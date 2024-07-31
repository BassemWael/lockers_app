import 'package:flutter/material.dart';
import 'package:lockerapp/classes/locker.dart';
import 'package:lockerapp/components/textformfield.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lockerapp/services/apiservice.dart';

void showAddLockerDialog(
    BuildContext context,
    double inputWidth,
    TextEditingController iDController,
    TextEditingController locationController,
    TextEditingController nocController,
    TextEditingController resMController,
    TextEditingController IDController,
    ApiService apiService) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      Future<Locker>? locker;
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.addLocker),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildTextFormField(iDController,
                      AppLocalizations.of(context)!.lockerId, inputWidth),
                  buildTextFormField(locationController,
                      AppLocalizations.of(context)!.location, inputWidth),
                  buildTextFormField(nocController,
                      AppLocalizations.of(context)!.numberOfCells, inputWidth),
                  buildTextFormField(
                      resMController,
                      AppLocalizations.of(context)!.reservationMode,
                      inputWidth),
                  buildTextFormField(IDController,
                      AppLocalizations.of(context)!.iD, inputWidth),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      bool isValid = true;
                      List<Locker> lockers = await apiService.getLockers();
                      for (var locker in lockers) {
                        if (locker.lockerId ==
                            int.tryParse(iDController.text)) {
                          isValid = false;
                          break;
                        }
                      }
                      if (isValid) {
                        await apiService.addLocker(
                          Locker(
                            lockerId: int.tryParse(iDController.text),
                            location: locationController.text,
                            numOfCells: int.tryParse(nocController.text),
                            reservationMode: int.tryParse(resMController.text),
                            id: IDController.text,
                          ),
                        );
                        Navigator.of(context)
                            .pop(); // Close the dialog after adding
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .lockerIdNotUnique)),
                        );
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.addLocker),
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
}
