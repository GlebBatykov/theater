import 'package:flutter/material.dart';
import 'package:flutter_theater_example_application/fibonacci.dart';
import 'package:get_it/get_it.dart';
import 'package:theater/theater.dart';

class FibonacciCalculator extends StatefulWidget {
  const FibonacciCalculator({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FibonacciCalculatorState();
}

class _FibonacciCalculatorState extends State<FibonacciCalculator> {
  final TextEditingController _textEditingController = TextEditingController();

  late final LocalActorRef _ref;

  String _result = '';

  // Get dependency for [GetIt]
  Future<void> _initialize() async {
    // Get instance of [LocalActorRef] with name 'test_actor_ref'
    _ref = await GetIt.instance
        .getAsync<LocalActorRef>(instanceName: 'test_actor_ref');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialize(),
        builder: (context, snapshot) {
          return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                const Text('Fibonacci calculator',
                    style: TextStyle(fontSize: 20)),
                TextFormField(
                    controller: _textEditingController,
                    keyboardType: TextInputType.number),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: ElevatedButton(
                      style: ButtonStyle(
                          minimumSize:
                              MaterialStateProperty.all(const Size(125, 50))),
                      onPressed: () async {
                        if (_textEditingController.text.isNotEmpty) {
                          var number = int.parse(_textEditingController.text);

                          late int result;

                          // Check number
                          if (number < 36) {
                            result = Fibonacci.calculate(number);
                          } else {
                            // Send message to actor
                            var subscription = _ref.send(number);

                            // Wait response from actor
                            var response = await subscription.stream.first;

                            result = (response as MessageResult).data;
                          }

                          setState(() {
                            // Set new state of _result
                            _result = result.toString();
                          });
                        } else {
                          // Show snack bar if field is empty
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Field is empty')));
                        }
                      },
                      child: const Text('Calculate',
                          style: TextStyle(fontSize: 16))),
                ),
                if (_result.isNotEmpty)
                  Text('Result: ' + _result,
                      style: const TextStyle(fontSize: 16))
              ]));
        });
  }
}
