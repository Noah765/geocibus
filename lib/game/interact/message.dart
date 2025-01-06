import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geocibus/models/region.dart';

class InteractMessage extends StatefulWidget {
  const InteractMessage({super.key});

  @override
  State<InteractMessage> createState() => _InteractMessageState();
}

class _InteractMessageState extends State<InteractMessage> {
  late final String message;

  @override
  void initState() {
    super.initState();

    final region = context.read<Region>();
    //if (region.isTradeBlocked) {
    //  //message = ;
    //  return;
    //}
  }

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(context.read<Region>().name, style: Theme.of(context).textTheme.headlineSmall),
            const Text('stst'),
          ],
        ),
      ),
    );
  }
}
