#include <math.h>
#include "sagitta_types.h"
#include "sagitta_config.h"

/**
 * ConvectiveCoolingP implements forced and natural convective cooling
 * according to IEEE 738-2012 and Morgan empirical models.
 */
module ConvectiveCoolingP {
  provides {
    interface ConvectiveCooling;
  }
}
implementation {

  /* Dynamic viscosity of air polynomial fit vs film temperature */
  static float getAirViscosity(float filmTempC) {
    /* Sutherland-like approximation for dynamic viscosity (Pa * s) */
    return (1.458e-6f * powf(filmTempC + 273.15f, 1.5f)) / (filmTempC + 273.15f + 110.4f);
  }

  /* Air thermal conductivity polynomial fit vs film temperature */
  static float getAirConductivity(float filmTempC) {
    /* W / (m * K) */
    return 2.424e-2f + 7.477e-5f * filmTempC - 4.407e-9f * filmTempC * filmTempC;
  }

  /* Air density based on atmospheric film temperature and standard pressure */
  static float getAirDensity(float filmTempC) {
    /* kg / m^3 at sea level */
    return 1.293f * (273.15f / (filmTempC + 273.15f));
  }

  command float ConvectiveCooling.computeReynoldsNumber(
    float diameterM,
    float filmTempC,
    float windSpeedMps
  ) {
    float rho = getAirDensity(filmTempC);
    float mu = getAirViscosity(filmTempC);
    if (mu <= 0.0f) {
      return 0.0f;
    }
    return (diameterM * rho * windSpeedMps) / mu;
  }

  command float ConvectiveCooling.computeWindDirectionFactor(float windYawDeg) {
    /* Angle between wind direction and conductor axis: 0 to 90 degrees */
    float rad = fabsf(windYawDeg) * (3.14159265f / 180.0f);
    if (rad > 1.5707963f) {
      rad = 3.14159265f - rad;
    }
    /* IEEE 738 wind direction factor polynomial */
    float k = 1.194f - cosf(rad) + 0.194f * cosf(2.0f * rad) + 0.368f * sinf(2.0f * rad);
    if (k < 0.2f) {
      k = 0.2f; /* Minimum wind cooling factor */
    }
    return k;
  }

  command float ConvectiveCooling.computeConvectiveLoss(
    float diameterM,
    float conductorTempC,
    float ambientTempC,
    float windSpeedMps,
    float windYawDeg
  ) {
    float deltaT = conductorTempC - ambientTempC;
    if (deltaT <= 0.0f) {
      return 0.0f;
    }

    float filmTempC = (conductorTempC + ambientTempC) * 0.5f;
    float kf = getAirConductivity(filmTempC);
    float rho = getAirDensity(filmTempC);
    float re = call ConvectiveCooling.computeReynoldsNumber(diameterM, filmTempC, windSpeedMps);
    float kAngle = call ConvectiveCooling.computeWindDirectionFactor(windYawDeg);

    /* Forced convection: Low wind equation (Re <= 2650) */
    float qc1 = (1.01f + 0.0372f * powf(re, 0.52f)) * kf * deltaT * kAngle;

    /* Forced convection: High wind equation (Re > 2650) */
    float qc2 = (0.0119f * powf(re, 0.6f)) * kf * deltaT * kAngle;

    /* Natural convection: Still air equation */
    float qcn = 0.0205f * powf(rho, 0.5f) * powf(diameterM, 0.75f) * powf(deltaT, 1.25f);

    /* Select maximum heat dissipation mechanism */
    float qcForced = (qc1 > qc2) ? qc1 : qc2;
    return (qcForced > qcn) ? qcForced : qcn;
  }
}
