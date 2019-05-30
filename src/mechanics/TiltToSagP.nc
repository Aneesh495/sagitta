#include <math.h>
#include "sagitta_types.h"
#include "catenary_params.h"

/**
 * TiltToSagP filters MEMS accelerometer tilt readings and transforms
 * inclination angle into mid-span sagitta and conductor tension.
 */
module TiltToSagP {
  provides {
    interface TiltToSag;
  }
}
implementation {
  float m_offsetM;
  float m_spanLengthM;
  bool m_isConfigured;

  /* Low-pass exponential moving average filter states */
  float m_filteredPitchDeg;
  float m_filteredRollDeg;
  bool m_filterInitialized;

  command error_t TiltToSag.configureMotePlacement(float offsetFromClampM, float spanLengthM) {
    if (offsetFromClampM <= 0.0f || spanLengthM <= 0.0f) {
      return SAGITTA_ERROR_INVALID_ARG;
    }
    m_offsetM = offsetFromClampM;
    m_spanLengthM = spanLengthM;
    m_isConfigured = TRUE;
    m_filterInitialized = FALSE;
    m_filteredPitchDeg = 0.0f;
    m_filteredRollDeg = 0.0f;
    return SAGITTA_SUCCESS;
  }

  command error_t TiltToSag.filterTiltAngles(
    int16_t accelX,
    int16_t accelY,
    int16_t accelZ,
    float* pitchAngleDegOut,
    float* rollAngleDegOut
  ) {
    if (!pitchAngleDegOut || !rollAngleDegOut) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    float ax = (float)accelX;
    float ay = (float)accelY;
    float az = (float)accelZ;

    /* Pitch (longitudinal inclination along conductor) */
    float pitchRad = atan2f(-ax, sqrtf(ay * ay + az * az));
    float pitchDeg = pitchRad * (180.0f / 3.14159265f);

    /* Roll (transverse swing across line axis) */
    float rollRad = atan2f(ay, az);
    float rollDeg = rollRad * (180.0f / 3.14159265f);

    /* IIR low-pass filter (alpha = 0.05 for static tilt isolation) */
    if (!m_filterInitialized) {
      m_filteredPitchDeg = pitchDeg;
      m_filteredRollDeg = rollDeg;
      m_filterInitialized = TRUE;
    } else {
      float alpha = 0.05f;
      m_filteredPitchDeg = alpha * pitchDeg + (1.0f - alpha) * m_filteredPitchDeg;
      m_filteredRollDeg = alpha * rollDeg + (1.0f - alpha) * m_filteredRollDeg;
    }

    *pitchAngleDegOut = m_filteredPitchDeg;
    *rollAngleDegOut = m_filteredRollDeg;
    return SAGITTA_SUCCESS;
  }

  command float TiltToSag.convertTiltToSagitta(float pitchAngleDeg) {
    if (!m_isConfigured) {
      return 0.0f;
    }

    float pitchRad = fabsf(pitchAngleDeg) * (3.14159265f / 180.0f);
    float tanTheta = tanf(pitchRad);

    /* In parabolic geometry: dy/dx = (4 * s / L) * (1 - 2 * x / L) */
    /* At mounting offset x_m: s = tan(theta) * L / (4 * (1 - 2 * x_m / L)) */
    float factor = 4.0f * (1.0f - 2.0f * (m_offsetM / m_spanLengthM));
    if (factor <= 0.01f) {
      factor = 0.01f;
    }

    return (tanTheta * m_spanLengthM) / factor;
  }

  command float TiltToSag.convertTiltToTension(float pitchAngleDeg, float linearWeightNpm) {
    if (!m_isConfigured || linearWeightNpm <= 0.0f) {
      return 0.0f;
    }

    float sag = call TiltToSag.convertTiltToSagitta(pitchAngleDeg);
    if (sag <= 0.05f) {
      return 50000.0f; /* High tension bound */
    }

    /* H = (w * L^2) / (8 * s) */
    return (linearWeightNpm * m_spanLengthM * m_spanLengthM) / (8.0f * sag);
  }
}
