import 'dart:async';

class Subtotal {
  int _counter = 0;

  final _controller = StreamController<int>();
  final _incController = StreamController<int>();

  Stream<int> get counterStream => _controller.stream;

  StreamSink<int> get counterSink => _controller.sink;

  StreamSink<int> get incSink => _incController.sink;

  Subtotal() {
    _controller.add(_counter);
    _incController.stream.listen(_increment);
  }

  void _increment(int a) {
    _controller.add(a);
  }

  void dispose() {
    _controller.close();
    _incController.close();
  }
}
