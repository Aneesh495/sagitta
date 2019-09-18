#include "sagitta_types.h"

/**
 * CordicTrig interface provides hardware-efficient coordinate rotation
 * digital computer (CORDIC) trigonometric and vectoring operations.
 */
interface CordicTrig {
  /**
   * Computes sine and cosine simultaneously using CORDIC rotation mode.
   * @param angleQ15 Input angle in Q15 format (-pi to +pi mapped to -32768 to +32767)
   * @param sinOut Pointer to store resulting sine in Q15 format
   * @param cosOut Pointer to store resulting cosine in Q15 format
   */
  command void computeSinCos(q15_t angleQ15, q15_t* sinOut, q15_t* cosOut);

  /**
   * Computes vector magnitude and phase angle using CORDIC vectoring mode.
   * @param x In-phase Cartesian coordinate in Q15
   * @param y Quadrature Cartesian coordinate in Q15
   * @param magnitudeOut Pointer to store vector magnitude in Q15
   * @param angleOut Pointer to store phase angle in Q15
   */
  command void cartesianToPolar(q15_t x, q15_t y, q15_t* magnitudeOut, q15_t* angleOut);

  /**
   * Computes fast fixed-point square root using CORDIC iteration.
   * @param valueQ31 Non-negative Q31 radicand
   * @return Square root in Q15 format
   */
  command q15_t fixedSqrt(q31_t valueQ31);
}
