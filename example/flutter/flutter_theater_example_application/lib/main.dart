import 'package:flutter/material.dart';
import 'package:flutter_theater_example_application/widget/application.dart';
import 'package:flutter_theater_example_application/injection_container.dart';

void main() async {
  // Initialize dependencies
  await InjectionContainer.initialize();

  // Run application
  runApp(const Application());
}
