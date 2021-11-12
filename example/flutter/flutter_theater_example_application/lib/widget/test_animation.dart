import 'package:flutter/material.dart';

// Widget of animation
class TestAnimation extends StatefulWidget {
  const TestAnimation({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TestAnimationState();
}

class _TestAnimationState extends State<TestAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..repeat(reverse: true);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      var biggest = constrains.biggest;

      return Stack(
        children: [
          PositionedTransition(
            rect: RelativeRectTween(
                    begin: RelativeRect.fromSize(
                        const Rect.fromLTWH(0, 0, 25, 25), biggest),
                    end: RelativeRect.fromSize(
                        Rect.fromLTWH(
                            biggest.width - 25, biggest.height - 25, 25, 25),
                        biggest))
                .animate(CurvedAnimation(
                    parent: _animationController, curve: Curves.ease)),
            child: Container(
              color: Colors.blue,
            ),
          )
        ],
      );
    });
  }
}
