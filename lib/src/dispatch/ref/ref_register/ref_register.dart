part of theater.dispatch;

abstract class RefRegister<T extends Ref> {
  final List<T> _refs = [];

  List<T> get refs => List.unmodifiable(_refs);
}
