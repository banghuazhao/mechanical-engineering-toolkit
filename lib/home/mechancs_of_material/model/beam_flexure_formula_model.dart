class BeamFlexureFormulaModel {
  double? M;
  double? y;
  double? I;

  isValid() {
    if (M != null && I != null && I! > 0) {
      return true;
    }
    return false;
  }
}
