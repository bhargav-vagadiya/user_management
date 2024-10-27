import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Worker {
  final SendPort _commands;
  final ReceivePort _responses;
  final Map<int, Completer<Object?>> _activeRequests = {};
  int _idCounter = 0;
  bool _closed = false;

  Future<R> runTask<R>(FutureOr<R> Function() fun) async {
    if (_closed) throw StateError('Closed');
    final completer = Completer.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;
    _commands.send((id, fun));
    final result = await completer.future;
    if (result is RemoteError) {
      throw result;
    }
    return result;
  }

  static Future<Worker> spawn() async {
    // Create a receive port and add its initial message handler
    
    final initPort = RawReceivePort();
   
    RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
    final connection = Completer<(ReceivePort, SendPort)>.sync();
    initPort.handler = (initialMessage) {
      final commandPort = initialMessage as SendPort;
      connection.complete((
        ReceivePort.fromRawReceivePort(initPort),
        commandPort,
      ));
    };

    // Spawn the isolate.
    try {
      await Isolate.spawn(_startRemoteIsolate,
          (sendPort: initPort.sendPort, rootIsolateToken: rootIsolateToken),
          debugName: "background");
    } on Object {
      initPort.close();
      rethrow;
    }

    final (ReceivePort receivePort, SendPort sendPort) =
        await connection.future;

    return Worker._(receivePort, sendPort);
  }

  Worker._(this._responses, this._commands) {
    _responses.listen(_handleResponsesFromIsolate);
  }

  void _handleResponsesFromIsolate(dynamic message) {
    final (int id, Object? response) = message as (int, Object?);
    final completer = _activeRequests.remove(id)!;

    if (response is RemoteError) {
      completer.completeError(response);
    } else {
      completer.complete(response);
    }

    if (_closed && _activeRequests.isEmpty) _responses.close();
  }

  static _handleCommandsToIsolate(
    ReceivePort receivePort,
    SendPort sendPort,
  ) {
    receivePort.listen(<T>(message) async {
      if (message == 'shutdown') {
        receivePort.close();
        return;
      }
      final (int id, FutureOr<T> Function() fun) =
          message as (int, FutureOr<T> Function());
      try {
        final jsonData = await fun.call();
        sendPort.send((id, jsonData));
      } catch (e, s) {
        sendPort.send((id, RemoteError(e.toString(), s.toString())));
      }
    });
  }

  static void _startRemoteIsolate(
      ({SendPort sendPort, RootIsolateToken rootIsolateToken}) record) {
    BackgroundIsolateBinaryMessenger.ensureInitialized(record.rootIsolateToken);
    final receivePort = ReceivePort();
    record.sendPort.send(receivePort.sendPort);
    _handleCommandsToIsolate(receivePort, record.sendPort);
  }

  void close() {
    if (!_closed) {
      _closed = true;
      _commands.send('shutdown');
      if (_activeRequests.isEmpty) _responses.close();
      print('--- port closed --- ');
    }
  }
}
