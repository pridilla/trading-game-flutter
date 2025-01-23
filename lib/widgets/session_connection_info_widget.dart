import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:trading_game_flutter/providers/session_provider.dart';
import 'package:trading_game_flutter/providers/start_session_screen_color_provider.dart';

class SessionConnectionInfoWidget extends StatelessWidget {
  const SessionConnectionInfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(getFullPlayerClientUrl(context));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.watch<StartSessionScreenColorProvider>().color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.wifi,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                'Connect to session',
                style: GoogleFonts.geo(
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          QrImageView(
            data: getFullPlayerClientUrl(context),
            size: 200,
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  String getFullPlayerClientUrl(BuildContext context) {
    final sessionId = context.read<SessionProvider>().sessionId;
    return '${Uri.base.toString()}play/$sessionId';
  }
}
