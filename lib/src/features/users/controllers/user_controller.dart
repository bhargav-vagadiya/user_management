import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:user_management/src/features/users/models/user_model.dart';

class UserController {
  final Dio _dio = Dio();
  Future<Either<Fail, List<UserModel>>> getUsers() async {
    try {
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient dioClient) {
        dioClient.badCertificateCallback =
            ((X509Certificate cert, String host, int port) => true);
        return dioClient;
      };
      var response = await _dio.get('https://dummyjson.com/users');
      List<UserModel> users = await convertUserJsonToModel(response.data!);
      return Right(users);
    } catch (e) {
      return Left(Fail(e));
    }
  }

  Future<List<UserModel>> convertUserJsonToModel(
      Map<String, dynamic> json) async {
    return await compute(userModelFromJson, jsonEncode(json['users']));
  }
}
