import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injazathr/ui/widgets/confirmDialog.dart';

class LocationServiceDisabledDialog extends ConfirmDialog {
  LocationServiceDisabledDialog({Key? key})
      : super(
          key: key,
          title: 'map_location_service_disabled_title',
          content: 'map_location_service_disabled_content',
          cancel: 'map_location_dialog_cancel',
          ok: 'map_location_dialog_yes',
          onOk: () async {
            await Geolocator.openLocationSettings();
          },
        );
}

class LocationPermissionDisabledDialog extends ConfirmDialog {
  LocationPermissionDisabledDialog({Key? key})
      : super(
          key: key,
          title: 'map_no_location_permission_title',
          content: 'map_no_location_permission_content',
          cancel: 'map_location_dialog_cancel',
          ok: 'map_location_dialog_yes',
          onOk: () {},
        );
}