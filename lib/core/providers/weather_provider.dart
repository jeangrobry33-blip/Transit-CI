import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simule une condition météo globale (pluie) qui influence le trafic et
/// l'affluence des transports en commun ailleurs dans l'app.
class WeatherController extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;

  void setRaining(bool value) => state = value;
}

/// `true` quand la simulation de pluie est activée.
final isRainingProvider = NotifierProvider<WeatherController, bool>(WeatherController.new);
