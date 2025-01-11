import 'dart:collection' show Queue;

class RotationQueue {
  final Queue<Future<void> Function()> _queue = Queue();
  final int maxSize;
  bool _processing = false;

  RotationQueue({
    this.maxSize = 100,
  });

  Future<void> add(Future<void> Function() rotationTask) async {
    if (_queue.length >= maxSize) {
      print('Rotation queue is full, dropping rotation task');
      return;
    }

    _queue.add(rotationTask);
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_processing) return;
    _processing = true;

    try {
      while (_queue.isNotEmpty) {
        final task = _queue.removeFirst();
        await task();
      }
    } finally {
      _processing = false;
    }
  }
}
