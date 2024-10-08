import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:weather_app/models/forecast.dart';
import 'package:geolocator/geolocator.dart';

class WeatherForecastScreen extends StatefulWidget {
  const WeatherForecastScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WeatherForecastScreenState();
  }
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  late Future<List<Forecast>> futureForecast;
  String address = 'No location found';

  @override
  void initState() {
    super.initState();
    futureForecast = _getForecast();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<String> _getAddressFromLatLon(double lat, double lon) async {
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&key=AIzaSyBchtmnLnY8I2VwycHdhZGdY4V2qG86TAo';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['status'] == 'OK') {
        String formattedAddress = data['results'][9]['formatted_address'];
        return formattedAddress;
      } else {
        return 'No address found';
      }
    } else {
      throw Exception('Failed to load address');
    }
  }

  Future<List<Forecast>> _getForecast() async {
    Position position = await _determinePosition();
    address =
        await _getAddressFromLatLon(position.latitude, position.longitude);

    int _kelvinToCelsius(double kelvin) => (kelvin - 273.15).round();

    final Uri url = Uri.https('pro.openweathermap.org', '/data/2.5/forecast', {
      'lat': '${position.latitude}',
      'lon': '${position.longitude}',
      'appid': 'ee5fe5a605182416747d733c74bc0520'
    });

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      List<Forecast> forecastList = [];
      for (int i = 0; i < 10; i++) {
        forecastList.add(Forecast(
          maxTemp:
              _kelvinToCelsius(responseData['list'][i]['main']['temp_max']),
          minTemp:
              _kelvinToCelsius(responseData['list'][i]['main']['temp_min']),
          description: responseData['list'][i]['weather'][0]['description'],
          humidity: responseData['list'][i]['main']['humidity'],
        ));
      }
      return forecastList;
    } else {
      throw Exception('Failed to load weather forecast');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather Forecast"),
      ),
      body: RefreshIndicator(
        onRefresh: _getForecast,
        child: FutureBuilder<List<Forecast>>(
          future: futureForecast,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final forecast = snapshot.data!;
              return Column(
                children: [
                  Text(
                      "${address.split(',')[0]}, ${address.split(',')[1].replaceFirst('State of ', '')}"),
                  Expanded(
                    child: ListView.builder(
                      itemCount: forecast.length,
                      itemBuilder: (context, index) => ListTile(
                        leading: forecast[index].weatherIcon,
                        title: Row(
                          children: [
                            Text("${forecast[index].maxTemp}°"),
                            const SizedBox(width: 4),
                            Text("${forecast[index].minTemp}°",
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        subtitle: Text(forecast[index].description),
                        trailing:
                            Text("Humidity: ${forecast[index].humidity}%"),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: Text("No data available"));
            }
          },
        ),
      ),
    );
  }
}
