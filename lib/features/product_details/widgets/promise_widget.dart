import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class PromiseWidget extends StatelessWidget {
  const PromiseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double  width = 30;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Column(children: [
        SizedBox(width: width, child: Image.asset(Images.sevenDayEasyReturn),),

          ])),
      const SizedBox(width: Dimensions.paddingSizeDefault),

        Expanded(child: Column(children: [
          SizedBox(width: width, child: Image.asset(Images.safePayment),),
         ])),
      const SizedBox(width: Dimensions.paddingSizeDefault,),


        Expanded(child: Column(children: [
          SizedBox(width: width, child: Image.asset(Images.hundredParAuthentic),),

        ])),
        const SizedBox(width: Dimensions.paddingSizeDefault),

    ],);
  }
}
