import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../helper/colors.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.staggeredDotsWave(
        color: primaryColor,
        size: 60,
      ),
    );
  }
}

class LoadingWithBackground extends StatelessWidget {
  final bool isLoading;

  const LoadingWithBackground(this.isLoading, {super.key});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isLoading,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.black.withOpacity(0.4),
        child: Loading(),
      ),
    );
  }
}
