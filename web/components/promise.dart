@JS()
library Promise;

import "package:js/js.dart";

@JS()
class Promise<T> {

    external factory Promise(void Function(void Function(T value) accept, void Function(dynamic reason) reject) executor);

    external static Promise<T> all<T>(Iterable<Promise<T>> iterable);
    external static Promise<T> allSettled<T>(Iterable<Promise<T>> iterable);
    external static Promise<T> race<T>(Iterable<Promise<T>> iterable);
    external static Promise<T> reject<T>(dynamic reason);
    external static Promise<T> resolve<T>(T value);

    @JS("catch")
    external Promise<T> catchError(dynamic Function(dynamic reason) onRejected);
    external Promise<T> then(T Function(T value) onFulfilled, [T Function(dynamic reason) onRejected]);
    @JS("finally")
    external Promise<T> finallyDo(void Function() onFinally);
}