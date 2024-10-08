import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gps_module_test/helper/app_config.dart';
import '../element/custom_text.dart';
import 'page_gngga.dart';

RxString gngllSentence = "".obs;

class GNGLLParser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // GNGLL cümlesini işleyin
    Map<String, String> parsedData = parseGNGLL(gngllSentence.value);

    return Center(
      child: Container(
         height: 250, // Yüksekliği ihtiyaca göre ayarlayabilirsiniz
        width: App(context).appWidth(100),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CustomText(
                text: "GNGLL",
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  item("Fix Durumu", parsedData['status'].toString()),
                  item("Enlem", parsedData['latitude'].toString()),
                  item("Boylam", parsedData['longitude'].toString()),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  item("Zaman", "${parsedData['time']}UTC"),
                ],
              ),
            ],
          ),
        ),
      ),
    );

  }
  Map<String, String> parseGNGLL(String sentence) {
    // Cümleyi parçalara ayırın
    List<String> parts = sentence.split(',');

    // Cümle uygun değilse varsayılan değerler döndür
    if (parts.isEmpty || parts[0] != '\$GNGLL') {
      return {
        'status': ' - ',
        'latitude': ' - ',
        'longitude': ' - ',
        'time': ' - ',
      };
    }

    // Eksik veri kontrolü ve çıkarma
    String latitude = (parts.length > 1 && parts[1].isNotEmpty) ? parseLatitudeLongitude(parts[1], parts[2]) : ' - ';
    String longitude = (parts.length > 3 && parts[3].isNotEmpty) ? parseLatitudeLongitude(parts[3], parts[4]) : ' - ';
    String time = (parts.length > 5 && parts[5].isNotEmpty) ? parseTime(parts[5]) : ' - ';
    String status = (parts.length > 6 && parts[6].isNotEmpty) ? (parts[6] == 'A' ? 'Aktif' : 'Geçersiz') : ' - ';

    return {
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'time': time,
    };
  }

  String parseTime(String value) {
    if (value.isEmpty || value.length < 6) return ' - ';

    // Zamanı saat:dakika:saniye formatına çevir
    return '${value.substring(0, 2)}:${value.substring(2, 4)}:${value.substring(4, 6)}';
  }

  String parseLatitudeLongitude(String value, String direction) {
    if (value.isEmpty || direction.isEmpty) return ' - ';

    double degrees = double.parse(value.substring(0, 2));
    double minutes = double.parse(value.substring(2));
    double result = degrees + (minutes / 60);

    if (direction == 'S' || direction == 'W') {
      result *= -1;
    }

    return result.toStringAsFixed(4);
  }


}
