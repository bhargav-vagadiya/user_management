import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DetailsTile extends StatelessWidget {
  const DetailsTile({
    super.key,
    required this.title1,
    required this.value1,
    required this.title2,
    required this.value2,
  });

  final String title1;
  final String value1;
  final String title2;
  final String value2;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                '$title1:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  value1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        ),
        SizedBox(width: 5.w),
        Expanded(
          child: Row(
            children: [
              Text(
                '$title2:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  value2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}