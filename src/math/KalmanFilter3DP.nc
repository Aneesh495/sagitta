#include <math.h>
#include "sagitta_types.h"

/**
 * KalmanFilter3DP implements a 3-state Kalman filter tracking:
 * x = [theta (inclination angle), omega (angular velocity), sag (midspan sagitta)]^T
 */
module KalmanFilter3DP {
  provides {
    interface KalmanState;
  }
}
implementation {
  /* State vector: [theta, omega, sag] */
  float m_x[3];

  /* 3x3 State error covariance matrix */
  float m_P[3][3];

  /* Noise parameters */
  float m_qProcess;
  float m_rMeasurement;

  command void KalmanState.initState(
    float initialAngleDeg,
    float initialSagM,
    float processNoiseQ,
    float measurementNoiseR
  ) {
    m_x[0] = initialAngleDeg;
    m_x[1] = 0.0f;
    m_x[2] = initialSagM;

    m_qProcess = (processNoiseQ > 0.0f) ? processNoiseQ : 0.01f;
    m_rMeasurement = (measurementNoiseR > 0.0f) ? measurementNoiseR : 0.1f;

    /* Initialize P as diagonal */
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        m_P[i][j] = (i == j) ? 1.0f : 0.0f;
      }
    }
  }

  command void KalmanState.predictState(float dtSeconds) {
    if (dtSeconds <= 0.0f) return;

    /* Kinematic transition:
     * theta_new = theta + omega * dt
     * omega_new = omega
     * sag_new = sag_k
     */
    m_x[0] += m_x[1] * dtSeconds;

    /* Update covariance: P = F * P * F^T + Q */
    m_P[0][0] += (2.0f * m_P[0][1] * dtSeconds + m_P[1][1] * dtSeconds * dtSeconds) + m_qProcess;
    m_P[0][1] += m_P[1][1] * dtSeconds;
    m_P[1][0] += m_P[1][1] * dtSeconds;
    m_P[1][1] += m_qProcess;
    m_P[2][2] += m_qProcess * 0.1f;
  }

  command void KalmanState.updateMeasurement(float measuredAngleDeg) {
    /* Measurement matrix H = [1, 0, 0] */
    /* Innovation residual: y = z - H * x */
    float residual = measuredAngleDeg - m_x[0];

    /* Innovation covariance: S = H * P * H^T + R = P[0][0] + R */
    float s = m_P[0][0] + m_rMeasurement;
    if (s <= 1e-6f) s = 1e-6f;

    /* Kalman gain: K = P * H^T / S */
    float k[3];
    k[0] = m_P[0][0] / s;
    k[1] = m_P[1][0] / s;
    k[2] = m_P[2][0] / s;

    /* State update: x = x + K * y */
    m_x[0] += k[0] * residual;
    m_x[1] += k[1] * residual;
    m_x[2] += k[2] * residual;

    /* Covariance update: P = (I - K * H) * P */
    float p00 = m_P[0][0];
    float p01 = m_P[0][1];
    float p02 = m_P[0][2];

    for (int j = 0; j < 3; j++) {
      m_P[0][j] -= k[0] * ((j == 0) ? p00 : (j == 1) ? p01 : p02);
      m_P[1][j] -= k[1] * ((j == 0) ? p00 : (j == 1) ? p01 : p02);
      m_P[2][j] -= k[2] * ((j == 0) ? p00 : (j == 1) ? p01 : p02);
    }
  }

  command void KalmanState.getFilteredState(float* angleDegOut, float* sagMOut) {
    if (angleDegOut) *angleDegOut = m_x[0];
    if (sagMOut) *sagMOut = m_x[2];
  }
}
