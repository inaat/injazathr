import 'package:flutter/material.dart';
import 'package:injazathr/ui/styles/colors.dart';

class ConfirmDialog extends StatelessWidget {
  final Function onOk;
  final String title;
  final String content;
  final String cancel;
  final String ok;

  const ConfirmDialog({
    Key? key,
    required this.onOk,
    required this.title,
    required this.content,
    this.cancel = "delete_dialog_cancel",
    this.ok = "backup_controller_page_background_battery_info_ok",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancel,
            style: const TextStyle(
              color: primaryColorGradient,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            onOk();
            Navigator.of(context).pop(true);
          },
          child: Text(
            ok,
            style: TextStyle(
              color: Colors.red[400],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
