#include "sagitta_types.h"

/**
 * ConvectiveCooling interface evaluates forced and natural convection
 * terms according to IEEE 738 and Morgan formulations.
 */
interface ConvectiveCooling {
  /**
   * Computes convective heat loss rate per unit conductor length.
   * @param diameterM Conductor outer diameter in meters
   * @param conductorTempC Conductor temperature in deg C
   * @param ambientTempC Ambient temperature in deg C
   * @param windSpeedMps Wind speed in m/s
   * @param windYawDeg Wind attack yaw angle relative to line axis
   * @return Convective heat dissipation in Watts per meter (W/m)
   */
  command float computeConvectiveLoss(
    float diameterM,
    float conductorTempC,
    float ambientTempC,
    float windSpeedMps,
    float windYawDeg
  );

  /**
   * Computes Reynolds number based on boundary film properties.
   * @param diameterM Conductor outer diameter in meters
   * @param filmTempC Mean boundary film temperature (Tc + Ta) / 2
   * @param windSpeedMps Wind speed in m/s
   * @return Dimensionless Reynolds number
   */
  command float computeReynoldsNumber(
    float diameterM,
    float filmTempC,
    float windSpeedMps
  );

  /**
   * Computes wind direction multiplier factor K_angle.
   * @param windYawDeg Angle between wind vector and conductor axis (0 to 90 deg)
   * @return Dimensionless angle correction multiplier
   */
  command float computeWindDirectionFactor(float windYawDeg);
}
