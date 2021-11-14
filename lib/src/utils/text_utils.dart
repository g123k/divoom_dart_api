extension TextExtensions on String {
  int count(String character) {
    assert(character.length == 1);

    int counter = 0;
    for (int i = 0; i != length; i++) {
      if (this[i] == character) {
        counter++;
      }
    }

    return counter;
  }
}
