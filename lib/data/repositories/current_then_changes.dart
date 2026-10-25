import 'dart:async';

/// A stream that emits [current]'s value on listen and then every value of
/// [changes]. Subscribes to [changes] at once, so no change made between
/// listening and the first value is lost (unlike an `async*` generator).
Stream<T> currentThenChanges<T>(T Function() current, Stream<T> changes) {
  late final StreamController<T> controller;
  StreamSubscription<T>? subscription;
  controller = StreamController<T>(
    onListen: () {
      controller.add(current());
      subscription = changes.listen(
        controller.add,
        onError: controller.addError,
      );
    },
    onCancel: () => subscription?.cancel(),
  );
  return controller.stream;
}
