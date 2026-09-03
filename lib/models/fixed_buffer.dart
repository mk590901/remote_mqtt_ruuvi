class FixedBuffer<T> {
  final int bufferSize;
  final List<T> _buffer = [];

  FixedBuffer(this.bufferSize) {
    if (bufferSize <= 0) {
      throw ArgumentError('bufferSize must be > 0');
    }
  }

  /// Adds an element to the end of the buffer.
  /// If the buffer is already full, shifts all elements to the left (removes the oldest)
  /// and writes the new element to the end.
   void put(T element) {
    if (_buffer.length < bufferSize) {
      _buffer.add(element);
    } else {
      _buffer.removeAt(0); // сдвиг влево
      _buffer.add(element);
    }
  }

  /// Returns a copy of the current contents of the buffer.
  List<T> getList() => List<T>.from(_buffer);

  /// Current number of elements.
  int get length => _buffer.length;

  /// Is the buffer full?
  bool get isFull => _buffer.length == bufferSize;

  /// Clear buffer.
  void clear() => _buffer.clear();
}