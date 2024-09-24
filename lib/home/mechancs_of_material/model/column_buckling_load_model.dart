class ColumnBucklingLoadModel {
  double? E;
  double? I;
  double? L;

  isValid() {
    if (E != null && E! > 0 && I != null && I! > 0 && L != null && L! > 0) {
      return true;
    }
    return false;
  }
}
