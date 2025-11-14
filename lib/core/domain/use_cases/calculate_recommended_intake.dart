class CalculateRecommendedIntake {
  double call(double weightKg) {
    // A common recommendation is 30-35 ml of water per kg of body weight.
    // We will use 35 ml/kg as a starting point.
    return weightKg * 35;
  }
}
