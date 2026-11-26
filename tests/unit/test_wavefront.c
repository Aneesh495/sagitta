#include <stdint.h>
#include <stdio.h>
#include <math.h>
#include "../test_runner.h"

static float solve_twfl_double_ended(
  uint32_t tA_s, uint32_t tA_ns,
  uint32_t tB_s, uint32_t tB_ns,
  float lineLengthM,
  float velocityMps
) {
  int64_t diffS = (int64_t)tA_s - (int64_t)tB_s;
  int64_t diffNs = (int64_t)tA_ns - (int64_t)tB_ns;
  double dt = (double)diffS + ((double)diffNs * 1e-9);

  double xf = ((double)lineLengthM + (double)velocityMps * dt) * 0.5;
  return (float)xf;
}

bool test_twfl_midpoint_fault(void) {
  float lineLen = 100000.0f; /* 100 km transmission line */
  float v = 2.94e8f; /* 294,000 km/s */

  /* Fault occurs exactly at midpoint (50 km) */
  /* Waves arrive at Mote A and Mote B at identical instants */
  float xf = solve_twfl_double_ended(10, 500000, 10, 500000, lineLen, v);
  TEST_ASSERT_NEAR(xf, 50000.0f, 1.0f);
  return true;
}

bool test_twfl_asymmetric_fault(void) {
  float lineLen = 100000.0f; /* 100 km line */
  float v = 2.94e8f;

  /* Fault occurs at x = 20,000 m (20 km from Mote A, 80 km from Mote B) */
  /* Distance to A: 20 km -> time = 20000 / 2.94e8 = 68.027 us */
  /* Distance to B: 80 km -> time = 80000 / 2.94e8 = 272.108 us */
  /* Arrival at A: 68,027 ns; Arrival at B: 272,108 ns */
  uint32_t tA_ns = 68027;
  uint32_t tB_ns = 272108;

  float xf = solve_twfl_double_ended(10, tA_ns, 10, tB_ns, lineLen, v);
  TEST_ASSERT_NEAR(xf, 20000.0f, 5.0f); /* Accurate within 5 meters! */
  return true;
}

bool test_twfl_sub_microsecond_precision_sensitivity(void) {
  float lineLen = 50000.0f; /* 50 km line */
  float v = 2.94e8f;

  /* Introduce a 100 nanosecond clock synchronization jitter */
  uint32_t tA_ns = 100000;
  uint32_t tB_ns = 100100; /* +100 ns delta */

  float xf1 = solve_twfl_double_ended(10, 100000, 10, 100000, lineLen, v);
  float xf2 = solve_twfl_double_ended(10, tA_ns, 10, tB_ns, lineLen, v);

  float errorMeters = fabsf(xf2 - xf1);
  /* 100 ns * 2.94e8 / 2 = 14.7 meters */
  TEST_ASSERT_NEAR(errorMeters, 14.7f, 0.5f);
  TEST_ASSERT(errorMeters < 30.0f); /* Within single tower span */
  return true;
}
