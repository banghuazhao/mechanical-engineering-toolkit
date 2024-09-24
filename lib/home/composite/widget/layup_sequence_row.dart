import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/layup_sequence_model.dart';

class LayupSequenceRow extends StatefulWidget {
  final LayupSequence layupSequence;
  final bool validate;

  const LayupSequenceRow(
      {Key? key, required this.layupSequence, required this.validate})
      : super(key: key);

  @override
  _LayupSequenceRowState createState() => _LayupSequenceRowState();
}

class _LayupSequenceRowState extends State<LayupSequenceRow> {
  validateLayupSequence(List<double>? layups) {
    if (layups == null) {
      return "Wrong layup sequence";
    } else if (layups.length > 1000000) {
      return "Too many layers";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              S.of(context).Layup_Sequence,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: TextField(
              decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  border: const OutlineInputBorder(),
                  labelText: "[xx/xx/xx/xx]msn",
                  errorText: widget.validate
                      ? validateLayupSequence(widget.layupSequence.layups)
                      : null),
              onChanged: (value) {
                widget.layupSequence.value = value;
              },
            ),
          )
        ],
      ),
    );
  }
}
