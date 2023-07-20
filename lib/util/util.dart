import 'dart:math';

double rescale(double value,
    {double oldMin = 0,
    double oldMax = 100,
    double newMin = 0,
    double newMax = 1}) {
  return (((value - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin;
}



double rescaleLogarithmically(double value,
    {double oldMin = 0,
    double oldMax = 100,
    double newMin = 0,
    double newMax = 1})
{
  return rescale(log(value), oldMin: log(oldMin), oldMax: log(oldMax), newMin: newMin, newMax: newMax);
}