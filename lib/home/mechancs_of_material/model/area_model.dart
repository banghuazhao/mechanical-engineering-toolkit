class Area {
  double? value;

  isValid() {
    return value != null && value! > 0;
  }
}
