import 'package:flutter/material.dart';

class DialogActions extends StatelessWidget {
  const DialogActions({super.key, required this.onContinueDialog, required this.onConfirm});

  final VoidCallback onContinueDialog;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: OutlinedButton(onPressed: onContinueDialog, child: const Text('Dialog weiterführen'))),
        Expanded(child: OutlinedButton(onPressed: onConfirm, child: const Text('Abschließen'))),
      ],
    );
  }
}
