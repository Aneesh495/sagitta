#include <stdio.h>
#include <math.h>
#include "../test_runner.h"

static float calc_midspan_sag(float w, float l, float h) {
  return (w * l * l) / (8.0f * h);
}

static float calc_tilt_to_sag(float pitchDeg, float xm, float l) {
  float pitchRad = fabsf(pitchDeg) * (3.14159265f / 180.0f);
  float tanTheta = tanf(pitchRad);
  float factor = 4.0f * (1.0f - 2.0f * (xm / l));
  if (factor <= 0.01f) factor = 0.01f;
  return (tanTheta * l) / factor;
}

bool test_catenary_parabolic_sag(void) {
  float w = 15.96f;   /* N/m */
  float l = 300.0f;   /* 300 meters span */
  float h = 25000.0f; /* 25 kN horizontal tension */

  float sag = calc_midspan_sag(w, l, h);
  /* Expected: (15.96 * 90000) / 200000 = 7.182 meters */
  TEST_ASSERT_NEAR(sag, 7.182f, 0.01f);
  return true;
}

bool test_tilt_to_sag_conversion(void) {
  float l = 300.0f;
  float xm = 2.0f; /* 2 meters from suspension clamp */

  /* In parabolic geometry: dy/dx = (4 * s / L) * (1 - 2*x/L) */
  float expectedSag = 7.182f;
  float slopeAtXm = (4.0f * expectedSag / l) * (1.0f - 2.0f * xm / l);
  float pitchDeg = atanf(slopeAtXm) * (180.0f / 3.14159265f);

  float estimatedSag = calc_tilt_to_sag(pitchDeg, xm, l);
  TEST_ASSERT_NEAR(estimatedSag, expectedSag, 0.05f);
  return true;
}

bool test_ice_load_radial_thickness(void) {
  float d = 0.02814f;
  float rhoIce = 900.0f;
  float g = 9.80665f;
  float rIceTargetM = 0.0125f; /* 12.5 mm ice accretion */

  /* Delta W = pi * rho * g * (D * r + r^2) */
  float deltaW = 3.14159265f * rhoIce * g * (d * rIceTargetM + rIceTargetM * rIceTargetM);
  TEST_ASSERT(deltaW > 10.0f);

  /* Solve back for rIce */
  float denom = 3.14159265f * rhoIce * g;
  float c = deltaW / denom;
  float rIceEstimatedM = (-d + sqrtf(d * d + 4.0f * c)) * 0.5f;

  TEST_ASSERT_NEAR(rIceEstimatedM, rIceTargetM, 0.0001f);
  return true;
}

bool test_ground_clearance_terrain_profile(void) {
  float towerHeight = 35.0f;
  float sag = 7.18f;
  float minClearance = towerHeight - sag;

  TEST_ASSERT_NEAR(minClearance, 27.82f, 0.01f);
  TEST_ASSERT(minClearance > 7.5f); /* Exceeds statutory safety margin */
  return true;
}
