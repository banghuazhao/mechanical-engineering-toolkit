abstract class BeamDeflectionSlope {
  double? E;
  double? I;
  double? L;
  double? f;
  isValid();
}

class BeamDeflectionSlopeModel extends BeamDeflectionSlope {
  double? E;
  double? I;
  double? L;
  double? f;
  isValid() {
    if (E != null &&
        E! > 0 &&
        I != null &&
        I! > 0 &&
        L != null &&
        L! > 0 &&
        f != null) {
      return true;
    }
    return false;
  }
}

class BeamDeflectionSlopeABModel extends BeamDeflectionSlope {
  double? E;
  double? I;
  double? L;
  double? f;
  double? a;
  isValid() {
    if (E != null &&
        E! > 0 &&
        I != null &&
        I! > 0 &&
        L != null &&
        L! > 0 &&
        f != null &&
        a != null &&
        a! >= 0) {
      return true;
    }
    return false;
  }
}
