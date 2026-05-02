import 'package:flutter/widgets.dart';

import 'src/wallet_data.dart';
import 'src/wallet_home.dart';

void main() {
  runApp(const WalletDemoApp());
}

class WalletDemoApp extends StatefulWidget {
  const WalletDemoApp({super.key});

  @override
  State<WalletDemoApp> createState() => _WalletDemoAppState();
}

class _WalletDemoAppState extends State<WalletDemoApp> {
  final WalletData _data = WalletData();

  @override
  void initState() {
    super.initState();
    _data.start();
  }

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Mosaic Wallet',
      color: const Color(0xFF0B0B0C),
      builder: (context, child) => WalletHome(data: _data),
    );
  }
}
