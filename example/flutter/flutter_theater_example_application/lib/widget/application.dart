import 'package:flutter/material.dart';
import 'package:flutter_theater_example_application/widget/fibonacci_calculator.dart';
import 'package:flutter_theater_example_application/widget/test_animation.dart';

class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_theater_example_application',
      home: Scaffold(
        body: Container(
          margin: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              FibonacciCalculator(),
              Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: SizedBox(
                    width: 200,
                    height: 150,
                    child: TestAnimation(),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
