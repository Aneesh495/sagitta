#include "sagitta_types.h"

/**
 * KalmanState interface implements a 3-state linear Kalman filter
 * for tracking conductor inclination, angular velocity, and mechanical sagitta.
 */
interface KalmanState {
  /**
   * Initializes state vector x = [theta, omega, sag]^T and covariance matrix P.
   * @param initialAngleDeg Initial inclination angle in degrees
   * @param initialSagM Initial sagitta in meters
   * @param processNoiseQ Process covariance scaling
   * @param measurementNoiseR Measurement covariance scaling
   */
  command void initState(
    float initialAngleDeg,
    float initialSagM,
    float processNoiseQ,
    float measurementNoiseR
  );

  /**
   * Executes time update (prediction step) using physical kinematic state transition.
   * @param dtSeconds Elapsed time step in seconds
   */
  command void predictState(float dtSeconds);

  /**
   * Executes measurement update (correction step) incorporating new accelerometer tilt.
   * @param measuredAngleDeg Observed inclination angle from MEMS accelerometer
   */
  command void updateMeasurement(float measuredAngleDeg);

  /**
   * Queries optimal filtered inclination and sagitta state estimates.
   * @param angleDegOut Pointer to store filtered angle in degrees
   * @param sagMOut Pointer to store filtered mid-span sag in meters
   */
  command void getFilteredState(float* angleDegOut, float* sagMOut);
}
