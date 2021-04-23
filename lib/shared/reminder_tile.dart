import 'package:expiry_reminder/models/user.dart';
import 'package:expiry_reminder/screens/form/edit_reminder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class ReminderTile extends StatefulWidget {
  final DocumentSnapshot documentRef;
  final String popUpPrimaryMessage;
  final bool isCompleted;
  const ReminderTile(
      {Key key, this.documentRef, this.popUpPrimaryMessage, this.isCompleted})
      : super(key: key);

  @override
  _ReminderTileState createState() => _ReminderTileState();
}

class _ReminderTileState extends State<ReminderTile> {
  final dateFormat = new DateFormat.yMd();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final reminderRef = Firestore.instance
        .collection('appUsers')
        .document(user.uid)
        .collection('reminders');

    final completedReminders = Firestore.instance
        .collection('appUsers')
        .document(user.uid)
        .collection('completedReminders');

    return Padding(
      padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
      child: Card(
        child: ListTile(
          onTap: () =>
              Get.to(() => EditReminder(docToEdit: widget.documentRef)),
          onLongPress: () {
            showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => CupertinoActionSheet(
                      actions: [
                        CupertinoActionSheetAction(
                            isDefaultAction: true,
                            onPressed: () {
                              if (widget.isCompleted == true) {
                                reminderRef.add({
                                  'productImage':
                                      widget.documentRef.data['productImage'],
                                  'productBarcode':
                                      widget.documentRef.data['productBarcode'],
                                  'reminderName':
                                      widget.documentRef.data['reminderName'],
                                  'reminderDate':
                                      widget.documentRef.data['reminderDate'],
                                  'reminderDesc':
                                      widget.documentRef.data['reminderDesc'],
                                  'isExpired':
                                      widget.documentRef.data['isExpired'],
                                  'expiryDate':
                                      widget.documentRef.data['expiryDate'],
                                }).whenComplete(() => widget
                                    .documentRef.reference
                                    .delete()
                                    .whenComplete(
                                        () => Navigator.pop(context)));
                              } else {
                                completedReminders.add({
                                  'productImage':
                                      widget.documentRef.data['productImage'],
                                  'productBarcode':
                                      widget.documentRef.data['productBarcode'],
                                  'reminderName':
                                      widget.documentRef.data['reminderName'],
                                  'reminderDate':
                                      widget.documentRef.data['reminderDate'],
                                  'reminderDesc':
                                      widget.documentRef.data['reminderDesc'],
                                  'isExpired':
                                      widget.documentRef.data['isExpired'],
                                  'expiryDate':
                                      widget.documentRef.data['expiryDate'],
                                }).whenComplete(() => widget
                                    .documentRef.reference
                                    .delete()
                                    .whenComplete(
                                        () => Navigator.pop(context)));
                              }
                            },
                            child: Text(widget.popUpPrimaryMessage)),
                        CupertinoActionSheetAction(
                            isDestructiveAction: true,
                            onPressed: () => widget.documentRef.reference
                                .delete()
                                .whenComplete(() => Navigator.pop(context)),
                            child: Text('Delete')),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ));
          },
          leading: CircleAvatar(radius: 25, backgroundColor: Colors.brown[300]),
          title: Text(
            widget.documentRef.data['reminderName'],
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('Expiring on' +
              dateFormat
                  .format(widget.documentRef.data['expiryDate'].toDate())),
        ),
      ),
    );
  }
}
