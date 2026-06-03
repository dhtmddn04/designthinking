import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Android Emulator에서 PC의 localhost로 접근할 때는 10.0.2.2 사용
  static const String baseUrl = 'http://172.21.27.192:3000/api';

  static Future<Map<String, dynamic>> signup({
    required String username,
    required String password,
    required String phone,
    required bool needsWheelchair,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'phone': phone,
        'needsWheelchair': needsWheelchair,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createReservation({
    required int userId,
    required String stopName,
    required String busNumber,
    required String reservedTime,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reservations'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'stopName': stopName,
        'busNumber': busNumber,
        'reservedTime': reservedTime,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> cancelReservation({
    required int userId,
    required String stopName,
    required String reservedTime,
  }) async {
    final request = http.Request('DELETE', Uri.parse('$baseUrl/reservations'));

    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({
      'userId': userId,
      'stopName': stopName,
      'reservedTime': reservedTime,
    });

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getUserReservations({
    required int userId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reservations/user/$userId'),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getAllReservations() async {
    final response = await http.get(Uri.parse('$baseUrl/reservations'));

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> submitOpinion({
    required int userId,
    required String stopName,
    required String congestionLevel,
    String? comment,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/opinions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'stopName': stopName,
        'congestionLevel': congestionLevel,
        'comment': comment,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getOpinionSummaries() async {
    final response = await http.get(Uri.parse('$baseUrl/opinions/summary/all'));

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getSchedules({
    required int userId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/schedules/user/$userId'),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addSchedule({
    required int userId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    required String buildingName,
    required String roomNumber,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/schedules'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
        'buildingName': buildingName,
        'roomNumber': roomNumber,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteSchedule({
    required int userId,
    required int scheduleId,
  }) async {
    final request = http.Request(
      'DELETE',
      Uri.parse('$baseUrl/schedules/$scheduleId'),
    );

    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({'userId': userId});

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getNextBusTimetable({
    required String stationName,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/bus/timetable/next',
    ).replace(queryParameters: {'stationName': stationName});

    final response = await http.get(uri);

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getRealtimeNextBus({
    required String stationName,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/bus/realtime/next',
    ).replace(queryParameters: {'stationName': stationName});

    final response = await http.get(uri);

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getBoardingRecommendation({
    required int userId,
    required String stationName,
    required String reservedTime,
  }) async {
    final uri = Uri.parse('$baseUrl/bus/boarding-recommendation').replace(
      queryParameters: {
        'userId': userId.toString(),
        'stationName': stationName,
        'reservedTime': reservedTime,
      },
    );

    final response = await http.get(uri);

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getBoardingStatus({
    required String stationName,
    required String busNumber,
    required String boardingTime,
  }) async {
    final uri = Uri.parse('$baseUrl/reservations/boarding-status').replace(
      queryParameters: {
        'stationName': stationName,
        'busNumber': busNumber,
        'boardingTime': boardingTime,
      },
    );

    final response = await http.get(uri);

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getWaitingCount({
    required String stationName,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/waiting-count',
    ).replace(queryParameters: {'station': stationName});

    final response = await http.get(uri);

    return jsonDecode(response.body);
  }

  /*//테스트용(평일)
  static Future<Map<String, dynamic>> getNextBusTimetable({
    required String stationName,
  }) async {
    final uri = Uri.parse('$baseUrl/bus/timetable/next').replace(
      queryParameters: {
        'stationName': stationName,
        'dayOfWeek': '월',
        'time': '09:00',
      },
    );

    final response = await http.get(uri);

    return jsonDecode(response.body);
  }*/
}
