abstract class CrossSectionModel {
  isValid();
}

class CrossSectionBHModel extends CrossSectionModel {
  double? b;
  double? h;

  isValid() {
    if (b != null && b! > 0 && h != null && h! > 0) {
      return true;
    }
    return false;
  }
}

class CrossSectionRModel extends CrossSectionModel {
  double? r;

  isValid() {
    if (r != null && r! > 0) {
      return true;
    }
    return false;
  }
}
