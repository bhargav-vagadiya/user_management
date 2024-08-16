import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_management/src/features/users/models/user_model.dart';
import 'package:user_management/src/features/users/providers/user_provider.dart';
import 'package:user_management/src/features/users/views/widgets/details_tile.dart';

class UserView extends StatelessWidget {
  const UserView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ChangeNotifierProvider(
          create: (context) => UserProvider()..getUsers(),
          builder: (context, child) {
            var provider = Provider.of<UserProvider>(context);
            return provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: [
                      SizedBox(height: 30.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                context.read<UserProvider>().orderByAge();
                              },
                              child: const Text('Age')),
                          ElevatedButton(
                              onPressed: () {
                                context.read<UserProvider>().orderByName();
                              },
                              child: const Text('Name')),
                        ],
                      ),
                      SizedBox(height: 30.h),
                      if (provider.errorString.isNotEmpty)
                        Center(
                          child: Text(
                            provider.errorString,
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              UserModel user = provider.users[index];
                              return Row(
                                children: [
                                  Image.network(
                                    user.image!,
                                    height: 50.h,
                                  ),
                                  SizedBox(width: 5.w),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        DetailsTile(
                                            title1: 'Name',
                                            value1:
                                                '${user.firstName} ${user.lastName}',
                                            title2: 'Dob',
                                            value2: user.birthDate!),
                                        DetailsTile(
                                            title1: 'Email',
                                            value1: '${user.email}',
                                            title2: 'Phone',
                                            value2: user.phone!),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const Divider();
                            },
                            itemCount: provider.users.length,
                          ),
                        )
                    ],
                  );
          },
        ),
      ),
    );
  }
}
