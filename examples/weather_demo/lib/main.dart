import 'package:flutter/widgets.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

import 'src/weather_data.dart';
import 'src/weather_home.dart';

void main() {
  runApp(const WeatherDemoApp());
}

class WeatherDemoApp extends StatefulWidget {
  const WeatherDemoApp({super.key});

  @override
  State<WeatherDemoApp> createState() => _WeatherDemoAppState();
}

class _WeatherDemoAppState extends State<WeatherDemoApp> {
  final WeatherStore _store = WeatherStore();

  @override
  void initState() {
    super.initState();
    _store.bootstrap();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MosaicApp(
      title: 'Mosaic Weather',
      builder: (context) => WeatherHome(store: _store),
    );
  }
}
