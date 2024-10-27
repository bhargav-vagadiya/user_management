import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:user_management/main.dart';
import 'package:user_management/src/features/users/models/user_model.dart';

class UserController {
  final Dio _dio = Dio();
  Future<Either<Fail, List<UserModel>>> getUsers() async {
    var response = await _dio.get('https://dummyjson.com/users');
    try {
      final users = await worker!.runTask(() {
        return userModelFromJson(jsonEncode(response.data!['users']));
      });
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
