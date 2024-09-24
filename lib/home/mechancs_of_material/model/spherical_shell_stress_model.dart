class SphericalShellStressModel {
  double? p;
  double? r;
  double? t;

  isValid() {
    if (p != null && r != null && r! > 0 && t != null && t! > 0) {
      return true;
    }
    return false;
  }
}
