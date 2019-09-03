#include <math.h>
#include "sagitta_types.h"

/**
 * CordicEngineP implements iterative fixed-point CORDIC algorithms for
 * computing trigonometric functions, vector transformations, and square roots.
 */
module CordicEngineP {
  provides {
    interface CordicTrig;
  }
}
implementation {
  /*
   * 16-iteration CORDIC arctangent lookup table in Q15 format:
   * atanTable[i] = round(atan(2^(-i)) * 32768 / pi)
   */
  static const q15_t CORDIC_ATAN_TABLE[16] = {
    8192,  /* atan(2^0)  = 45.000 deg -> 0.25000 * 32768 */
    4836,  /* atan(2^-1) = 26.565 deg -> 0.14758 * 32768 */
    2555,  /* atan(2^-2) = 14.036 deg -> 0.07798 * 32768 */
    1297,  /* atan(2^-3) =  7.125 deg -> 0.03958 * 32768 */
    651,   /* atan(2^-4) =  3.576 deg -> 0.01987 * 32768 */
    326,   /* atan(2^-5) =  1.790 deg -> 0.00994 * 32768 */
    163,   /* atan(2^-6) =  0.895 deg -> 0.00497 * 32768 */
    81,    /* atan(2^-7) =  0.448 deg -> 0.00249 * 32768 */
    41,    /* atan(2^-8) =  0.224 deg -> 0.00124 * 32768 */
    20,    /* atan(2^-9) =  0.112 deg -> 0.00062 * 32768 */
    10,    /* atan(2^-10)=  0.056 deg -> 0.00031 * 32768 */
    5,     /* atan(2^-11)=  0.028 deg -> 0.00016 * 32768 */
    3,     /* atan(2^-12)=  0.014 deg -> 0.00008 * 32768 */
    1,     /* atan(2^-13)=  0.007 deg -> 0.00004 * 32768 */
    1,     /* atan(2^-14)=  0.003 deg -> 0.00002 * 32768 */
    0      /* atan(2^-15)=  0.002 deg -> 0.00001 * 32768 */
  };

  /* CORDIC cumulative gain K = prod(1 / sqrt(1 + 2^(-2i))) = 0.607252935 */
  /* In Q15: round(0.607252935 * 32767) = 19898 */
  #define CORDIC_GAIN_Q15 ((q15_t)19898)

  command void CordicTrig.computeSinCos(q15_t angleQ15, q15_t* sinOut, q15_t* cosOut) {
    if (!sinOut || !cosOut) return;

    /* Pre-rotation to map angle into [-pi/2, +pi/2] (i.e. [-16384, +16384]) */
    int32_t x = (int32_t)CORDIC_GAIN_Q15;
    int32_t y = 0;
    int32_t z = (int32_t)angleQ15;

    if (z > 16384) {
      z -= 32768;
      x = -x;
    } else if (z < -16384) {
      z += 32768;
      x = -x;
    }

    /* 16 CORDIC rotation iterations */
    for (uint8_t i = 0; i < 16; i++) {
      int32_t xShift = x >> i;
      int32_t yShift = y >> i;
      q15_t dTheta = CORDIC_ATAN_TABLE[i];

      if (z >= 0) {
        x -= yShift;
        y += xShift;
        z -= dTheta;
      } else {
        x += yShift;
        y -= xShift;
        z += dTheta;
      }
    }

    /* Clamping to Q15 range */
    if (x > 32767) x = 32767;
    if (x < -32768) x = -32768;
    if (y > 32767) y = 32767;
    if (y < -32768) y = -32768;

    *cosOut = (q15_t)x;
    *sinOut = (q15_t)y;
  }

  command void CordicTrig.cartesianToPolar(q15_t xIn, q15_t yIn, q15_t* magnitudeOut, q15_t* angleOut) {
    if (!magnitudeOut || !angleOut) return;

    int32_t x = (int32_t)xIn;
    int32_t y = (int32_t)yIn;
    int32_t z = 0;

    /* If in left half-plane (x < 0), rotate by 180 degrees */
    if (x < 0) {
      x = -x;
      y = -y;
      z = (y >= 0) ? 32767 : -32768;
    }

    /* 16 CORDIC vectoring iterations: drive y to zero */
    for (uint8_t i = 0; i < 16; i++) {
      int32_t xShift = x >> i;
      int32_t yShift = y >> i;
      q15_t dTheta = CORDIC_ATAN_TABLE[i];

      if (y < 0) {
        x -= yShift;
        y += xShift;
        z -= dTheta;
      } else {
        x += yShift;
        y -= xShift;
        z += dTheta;
      }
    }

    /* Scale magnitude by 1/K = 1.646760258 in fixed-point */
    int32_t mag = (x * 19898) >> 15;
    if (mag > 32767) mag = 32767;

    *magnitudeOut = (q15_t)mag;
    *angleOut = (q15_t)z;
  }

  command q15_t CordicTrig.fixedSqrt(q31_t valueQ31) {
    if (valueQ31 <= 0) return 0;

    /* Non-restoring fixed-point integer square root */
    uint32_t rem = 0;
    uint32_t root = 0;
    uint32_t val = (uint32_t)valueQ31;

    for (int i = 0; i < 16; i++) {
      root <<= 1;
      rem = (rem << 2) | (val >> 30);
      val <<= 2;

      if (root < rem) {
        rem -= root | 1;
        root += 2;
      }
    }

    uint32_t result = root >> 1;
    return (result > 32767) ? 32767 : (q15_t)result;
  }
}
