import 'package:flutter/material.dart';
import 'package:meqate/models.dart';

class BackGroundWidget extends StatelessWidget {
  BackGroundWidget(this.currentPrayer, {Key? key}) : super(key: key);
  final Prayer? currentPrayer;

  var image = "assets/5.jpg";

  @override
  Widget build(BuildContext context) {
    if (currentPrayer != null) {
      switch (currentPrayer!.title) {
        case "الفجر":
          image = "assets/1.jpg";
          break;
        case "الشروق":
          image = "assets/1.jpg";
          break;
        case "الظهر":
          image = "assets/2.jpg";
          break;
        case "العصر":
          image = "assets/3.jpg";
          break;
        case "المغرب":
          image = "assets/4.jpg";
          break;
        case "لعشاء":
          image = "assets/5.jpg";
          break;
      }
    }
    return Stack(children: [
      Container(
        height: MediaQuery.of(context).size.height / 2.5,
        alignment: Alignment.topCenter,
        child: ClipRRect(
          borderRadius:
              const BorderRadius.only(bottomRight: Radius.circular(30), bottomLeft: Radius.circular(30)),
          child: Image.asset(image, fit: BoxFit.fitWidth, width: double.infinity),
        ),
      ),
      Container(
        alignment: Alignment.bottomRight,
        transform: Matrix4.translationValues(70, 270, 0.0),
        child: Opacity(
            opacity: 0.8, child: RotatedBox(quarterTurns: 1, child: Image.asset("assets/Asset 2.png"))),
      )
    ]
        // child: FlutterLogo(size: 200),
        );
  }
}
