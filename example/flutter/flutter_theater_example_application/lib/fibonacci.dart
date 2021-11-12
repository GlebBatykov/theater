abstract class Fibonacci {
  static int calculate(int number) =>
      number <= 2 ? 1 : calculate(number - 1) + calculate(number - 2);
}
