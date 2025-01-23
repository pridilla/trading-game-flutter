import 'dart:async';
import 'dart:convert';

import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:trading_game_flutter/model/depot_model.dart';
import 'package:trading_game_flutter/model/order_model.dart';
import 'package:trading_game_flutter/model/remaining_duration_response.dart';
import 'package:trading_game_flutter/model/session_response_model.dart';
import 'package:http/http.dart' as http;
import 'package:trading_game_flutter/model/user_model.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:fetch_client/fetch_client.dart';

class Connection {
  static final String baseUrl = "127.0.0.1:10000";

  static Future<SessionResponse> getNewSession() async {
    final response = await http.get(Uri.parse('http://$baseUrl/session'));

    if (response.statusCode == 200) {
      return SessionResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create a new session');
    }
  }

  static Future<void> startGame(String sessionId) async {
    final response =
        await http.post(Uri.parse('http://$baseUrl/$sessionId/start'));

    if (response.statusCode != 200) {
      throw Exception('Failed to start the game');
    }
  }

  static Future<User> createUser(String sessionId) async {
    final response =
        await http.get(Uri.parse('http://$baseUrl/$sessionId/user'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create a new user');
    }
  }

  static Future<User> activateUser(String sessionId, User user) async {
    final response = await http.put(
        Uri.parse('http://$baseUrl/$sessionId/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create a new user');
    }
  }

  static Stream<List<User>> getCreatedUsersStream(String sessionId) {
    return SSEClient.subscribeToSSE(
      url: 'http://$baseUrl/$sessionId/created-users',
      method: SSERequestType.GET,
      header: {'Accept': 'text/event-stream'},
    ).handleError((error) {}).map((event) {
      final List<dynamic> users = jsonDecode(event.data!);
      return users
          .map((user) => User.fromJson(user as Map<String, dynamic>))
          .toList();
    });
  }

  static Future<List<Order>> addOrder(String sessionId, Order order) async {
    print('Adding order: ${order.toJson()}');
    final response = await http.post(
        Uri.parse('http://$baseUrl/$sessionId/order'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(order.toJson()));

    if (response.statusCode != 200) {
      throw Exception('Failed to add order');
    }

    return (jsonDecode(response.body) as List)
        .map((order) => Order.fromJson(order as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Order>> deleteOrder(String sessionId, Order order) async {
    final response = await http.delete(
        Uri.parse('http://$baseUrl/$sessionId/order'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(order.toJson()));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete order');
    }

    return (jsonDecode(response.body) as List)
        .map((order) => Order.fromJson(order as Map<String, dynamic>))
        .toList();
  }

  static StreamTransformer<String, List<User>> sseTransformer =
      StreamTransformer<String, List<User>>.fromHandlers(
    handleData: (String data, EventSink<List<User>> sink) {
      final entries = data
          .split('\n')
          .where((entry) => entry.startsWith('data: '))
          .toList();
      final lastEntry =
          entries.isNotEmpty ? entries.last.substring(6).trimRight() : '';
      List<dynamic> users = jsonDecode(lastEntry);
      sink.add(users
          .map((user) => User.fromJson(user as Map<String, dynamic>))
          .toList());
    },
  );

  static StreamTransformer<String, RemainingDurationResponse>
      sseTransformerDuration =
      StreamTransformer<String, RemainingDurationResponse>.fromHandlers(
    handleData: (String data, EventSink<RemainingDurationResponse> sink) {
      final entries = data
          .split('\n')
          .where((entry) => entry.startsWith('data: '))
          .toList();
      final lastEntry =
          entries.isNotEmpty ? entries.last.substring(6).trimRight() : '';
      sink.add(RemainingDurationResponse.fromJson(jsonDecode(lastEntry)));
    },
  );

  static StreamTransformer<String, List<Order>> sseTransformerOrders =
      StreamTransformer<String, List<Order>>.fromHandlers(
    handleData: (String data, EventSink<List<Order>> sink) {
      final entries = data
          .split('\n')
          .where((entry) => entry.startsWith('data: '))
          .toList();
      final lastEntry =
          entries.isNotEmpty ? entries.last.substring(6).trimRight() : '';
      final List<dynamic> orders = jsonDecode(lastEntry);
      sink.add(orders
          .map((order) => Order.fromJson(order as Map<String, dynamic>))
          .toList());
    },
  );

  static StreamTransformer<String, List<Depot>> sseTransformerDepots =
  StreamTransformer<String, List<Depot>>.fromHandlers(
    handleData: (String data, EventSink<List<Depot>> sink) {
      final entries = data
          .split('\n')
          .where((entry) => entry.startsWith('data: '))
          .toList();
      final lastEntry =
      entries.isNotEmpty ? entries.last.substring(6).trimRight() : '';
      final List<dynamic> orders = jsonDecode(lastEntry);
      sink.add(orders
          .map((order) => Depot.fromJson(order as Map<String, dynamic>))
          .toList());
    },
  );

  static StreamTransformer<String, SessionResponse> sseTransformerSession =
      StreamTransformer<String, SessionResponse>.fromHandlers(
    handleData: (String data, EventSink<SessionResponse> sink) {
      final entries = data
          .split('\n')
          .where((entry) => entry.startsWith('data: '))
          .toList();
      final lastEntry =
          entries.isNotEmpty ? entries.last.substring(6).trimRight() : '';
      sink.add(SessionResponse.fromJson(jsonDecode(lastEntry)));
    },
  );

  static Future<Stream<List<User>>> sseTest(String sessionId) async {
    final uri = Uri.http(baseUrl, '/$sessionId/created-users');

    final fetchClient = FetchClient(mode: RequestMode.cors);
    final request = http.Request('GET', uri);
    final headers = {
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
    };
    request.headers.addAll(headers);
    final response = await fetchClient.send(request);
    return response.stream.transform(utf8.decoder).transform(sseTransformer);
  }

  static Future<Stream<RemainingDurationResponse>> sseTimer(
      String sessionId) async {
    final uri = Uri.http(baseUrl, '/$sessionId/timer');

    final fetchClient = FetchClient(mode: RequestMode.cors);
    final request = http.Request('GET', uri);
    final headers = {
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
    };
    request.headers.addAll(headers);
    final response = await fetchClient.send(request);
    return response.stream
        .transform(utf8.decoder)
        .transform(sseTransformerDuration);
  }

  static Future<Stream<List<Order>>> sseActiveOrders(String sessionId) async {
    final uri = Uri.http(baseUrl, '/$sessionId/active-orders');

    final fetchClient = FetchClient(mode: RequestMode.cors);
    final request = http.Request('GET', uri);
    final headers = {
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
    };
    request.headers.addAll(headers);
    final response = await fetchClient.send(request);
    return response.stream
        .transform(utf8.decoder)
        .transform(sseTransformerOrders);
  }

  static Future<Stream<SessionResponse>> sseSession(String sessionId) async {
    final uri = Uri.http(baseUrl, '/$sessionId/session-state');

    final fetchClient = FetchClient(mode: RequestMode.cors);
    final request = http.Request('GET', uri);
    final headers = {
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
    };
    request.headers.addAll(headers);
    final response = await fetchClient.send(request);
    return response.stream
        .transform(utf8.decoder)
        .transform(sseTransformerSession);
  }

  static Future<Stream<List<Depot>>> sseDepots(String sessionId) async {
    final uri = Uri.http(baseUrl, '/$sessionId/depots');

    final fetchClient = FetchClient(mode: RequestMode.cors);
    final request = http.Request('GET', uri);
    final headers = {
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
    };
    request.headers.addAll(headers);
    final response = await fetchClient.send(request);
    return response.stream
        .transform(utf8.decoder)
        .transform(sseTransformerDepots);
  }

  static Future<Stream<List<Order>>> sseExecutedOrders(String sessionId) async {
    final uri = Uri.http(baseUrl, '/$sessionId/executed-orders');

    final fetchClient = FetchClient(mode: RequestMode.cors);
    final request = http.Request('GET', uri);
    final headers = {
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
    };
    request.headers.addAll(headers);
    final response = await fetchClient.send(request);
    return response.stream
        .transform(utf8.decoder)
        .transform(sseTransformerOrders);
  }
}
