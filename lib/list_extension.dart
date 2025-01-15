extension ListExtension<T> on List<T> {
  List<T> separate(T separator) {
    if (isEmpty) return this;

    final children = <T>[];
    for (var i = 0; i < length; i++) {
      children.add(this[i]);

      if (length - i != 1) {
        children.add(separator);
      }
    }

    return children;
  }
}
