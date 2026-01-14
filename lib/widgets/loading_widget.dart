import 'package:amenities_kenya/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitWave(
        color: AppColors.lightPrimary,
        size: 50.0,
      ),
    );
  }
}