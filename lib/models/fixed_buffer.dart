class FixedBuffer<T> {
  final int bufferSize;
  final List<T> _buffer = [];

  FixedBuffer(this.bufferSize) {
    if (bufferSize <= 0) {
      throw ArgumentError('bufferSize must be > 0');
    }
  }

  /// Добавляет элемент в конец буфера.
  /// Если буфер уже заполнен — сдвигает все элементы влево (удаляет самый старый)
  /// и записывает новый элемент в конец.
  void put(T element) {
    if (_buffer.length < bufferSize) {
      _buffer.add(element);
    } else {
      _buffer.removeAt(0); // сдвиг влево
      _buffer.add(element);
    }
  }

  /// Возвращает копию текущего содержимого буфера.
  List<T> getList() => List<T>.from(_buffer);

  /// Текущее количество элементов
  int get length => _buffer.length;

  /// Заполнен ли буфер
  bool get isFull => _buffer.length == bufferSize;

  /// Очистить буфер
  void clear() => _buffer.clear();
}