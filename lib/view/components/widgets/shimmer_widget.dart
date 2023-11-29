import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../view_model/utils/colors.dart';

class ShimmerWidget extends StatelessWidget {
  final Widget child;

  const ShimmerWidget({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      child: child,
      baseColor: AppColors.grey,
      highlightColor: AppColors.orange.withOpacity(0.25),
    );
  }
}
