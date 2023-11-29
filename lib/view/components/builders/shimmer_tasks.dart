import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../view_model/utils/colors.dart';
import '../widgets/shimmer_widget.dart';

class ShimmerTasks extends StatelessWidget {
  const ShimmerTasks ({this.child,super.key});
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding:const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        return ShimmerWidget(
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: AppColors.grey.withOpacity(0.1),
              border: Border.all(
                color: Colors.orange,
                width: 3,
              ),
            ),
            child: child,
          ),
        );
      },
      separatorBuilder: (context, index) =>
      const SizedBox(
        height: 8,
      ),
      itemCount: 10,
    );
  }
}
