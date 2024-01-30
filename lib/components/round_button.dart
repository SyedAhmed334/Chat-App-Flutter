import 'package:flutter/material.dart';

import '../constants/colors.dart';
class RoundButton extends StatelessWidget {
  final String title;
  final void Function()? onTap;
  final bool loading;
  final Color color, textColor;

  const RoundButton(
      {super.key,
        required this.title,
        required this.onTap,
        this.textColor = AppColors.whiteColor,
        this.color = Colors.black,
        this.loading = false,
      });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading ? null : onTap,
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(50),
        ),
        child: loading ? const Center(child: CircularProgressIndicator(color: Colors.white,),) : Center(
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .displayMedium!
                .copyWith(fontSize: 16,color: textColor),
          ),
        ),
      ),
    );
  }
}