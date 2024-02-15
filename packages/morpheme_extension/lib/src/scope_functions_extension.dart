extension GEScopeFunctionsExtension<T> on T {
  /// Calls the specified function [block] with [it] value as its receiver and returns its result.
  void run(void Function(T it) block) => block(this);

  /// Calls the specified function [block] with [it] value as its argument and returns its result.
  R let<R>(R Function(T it) block) => block(this);

  /// Calls the specified function [block] with [it] value as its argument and returns `block` value.
  T also(void Function(T it) block) {
    block(this);
    return this;
  }

  /// Returns [T] value if it satisfies the given [predicate] or `null`, if it doesn't.
  T? takeIf(bool Function(T it) predicate) => predicate(this) ? this : null;

  /// Returns [T] value if it _does not_ satisfy the given [predicate] or `null`, if it does.
  T? takeUnless(bool Function(T it) predicate) =>
      !predicate(this) ? this : null;
}
