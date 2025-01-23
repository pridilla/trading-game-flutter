import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trading_game_flutter/connection/connection.dart';
import 'package:trading_game_flutter/const/constant.dart';
import 'package:trading_game_flutter/providers/session_provider.dart';
import 'package:trading_game_flutter/providers/user_info_provider.dart';

import '../model/depot_model.dart';

class DepotCardWidget extends StatefulWidget {
  DepotCardWidget({super.key});

  @override
  State<DepotCardWidget> createState() => _DepotCardWidgetState();
}

class _DepotCardWidgetState extends State<DepotCardWidget> {
  StreamSubscription<List<Depot>>? _subscription;

  Depot? depot;

  void _startSubscription (BuildContext context) async {
    final sessionId = context.read<SessionProvider>().sessionId;
    final userId = context.read<UserInfoProvider>().user!.id;

    _subscription = (await Connection.sseDepots(sessionId)).listen(
      (depots) {
        setState(() {
          depot = depots.where((depot) => userId.id == depot.userId.id).first;
        });
      },
      onError: (error) => print('Depots stream error: $error'));
  }

  void initState() {
    super.initState();
    _startSubscription(context);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'Depot',
              style: GoogleFonts.geo(
                fontSize: 15,
                color: Colors.white,
              )
            ),
            Row(
              children: [
                Text('Balance'),
                Spacer(),
                Text('${depot?.balance.toString() ?? '0'}$currencySymbol'),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Text('Stocks amount'),
                Spacer(),
                Text(depot?.stockAmount.toString() ?? '0'),
              ],
            ),
          ],
        ),
      )
    );
  }
}