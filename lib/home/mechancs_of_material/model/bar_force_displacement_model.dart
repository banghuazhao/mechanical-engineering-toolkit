class BarTorsionFormulaModel {
  double? p;
  double? l;
  double? e;
  double? area;

  isValid() {
    if (p != null &&
        l != null &&
        l! > 0 &&
        e != null &&
        e! > 0 &&
        area != null &&
        area! > 0) {
      return true;
    }
    return false;
  }
}
