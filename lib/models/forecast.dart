import 'package:flutter/material.dart';

class Forecast {
  const Forecast({
    required this.maxTemp,
    required this.minTemp,
    required this.description,
    required this.humidity,
  });

  final int maxTemp;
  final int minTemp;
  final String description;
  final int humidity;

  Icon get weatherIcon {
    switch (description.toLowerCase()) {
      case 'clear sky':
        return const Icon(Icons.wb_sunny, color: Colors.orange);
      case 'few clouds':
        return const Icon(Icons.cloud_outlined, color: Colors.grey);
      case 'scattered clouds':
        return const Icon(Icons.cloud, color: Colors.grey);
      case 'broken clouds':
        return const Icon(Icons.wb_cloudy_sharp, color: Colors.black38);
      case 'overcast clouds':
        return const Icon(Icons.filter_drama, color: Colors.grey);
      case 'shower rain':
        return const Icon(Icons.grain, color: Colors.lightBlueAccent);
      case 'rain':
        return const Icon(Icons.cloudy_snowing, color: Colors.blueGrey);
      case 'thunderstorm':
        return const Icon(Icons.thunderstorm, color: Colors.yellow);
      case 'snow':
        return const Icon(Icons.ac_unit, color: Colors.white);
      case 'mist':
        return const Icon(Icons.foggy, color: Colors.grey);
      default:
        return const Icon(Icons.help_outline, color: Colors.black);
    }
  }
}
