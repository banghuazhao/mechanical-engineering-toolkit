class BarTorsionFormulaModel {
  double? T;
  double? r;
  double? Ip;

  isValid() {
    if (T != null && r != null && r! > 0 && Ip != null && Ip! > 0) {
      return true;
    }
    return false;
  }
}
