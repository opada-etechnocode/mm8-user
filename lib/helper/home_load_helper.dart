import 'dart:async';

typedef HomeLoadTask = Future<void> Function();

class HomeLoadHelper {
  HomeLoadHelper._();

  static bool _isLoading = false;

  static Future<void> runInBatches(
    List<HomeLoadTask> tasks, {
    int batchSize = 4,
  }) async {
    for (var index = 0; index < tasks.length; index += batchSize) {
      final end = (index + batchSize < tasks.length) ? index + batchSize : tasks.length;
      await Future.wait(tasks.sublist(index, end).map((task) => task()));
    }
  }

  static Future<void> runGuarded(
    bool reload, {
    required List<HomeLoadTask> criticalTasks,
    required List<HomeLoadTask> secondaryTasks,
    List<HomeLoadTask> deferredTasks = const [],
  }) async {
    if (_isLoading && !reload) {
      return;
    }

    _isLoading = true;
    try {
      await runInBatches(criticalTasks, batchSize: 4);
      await runInBatches(secondaryTasks, batchSize: 4);
      if (deferredTasks.isNotEmpty) {
        unawaited(runInBatches(deferredTasks, batchSize: 3));
      }
    } finally {
      _isLoading = false;
    }
  }
}
