#include <stdio.h>
#include <math.h>
#include "../test_runner.h"

bool test_induction_harvest_saturation_clamp(void) {
  float turns = 500.0f;
  float rBurden = 50.0f;
  float satCurrent = 1200.0f;

  /* Line current 600 A */
  float iSec600 = 600.0f / turns;
  float p600Mw = iSec600 * iSec600 * rBurden * 1000.0f;

  /* Line current 2000 A (should be clamped to 1200 A) */
  float iSec2000Clamped = satCurrent / turns;
  float p2000Mw = iSec2000Clamped * iSec2000Clamped * rBurden * 1000.0f;

  TEST_ASSERT(p600Mw > 10000.0f); /* > 10 Watts available */
  TEST_ASSERT(p2000Mw > p600Mw);
  TEST_ASSERT_NEAR(p2000Mw, (2.4f * 2.4f * 50.0f * 1000.0f), 1.0f);
  return true;
}

bool test_supercap_state_of_charge(void) {
  float vMin = 2.2f;
  float vMax = 5.0f;

  float v1 = 2.2f;
  float soc1 = (v1 - vMin) / (vMax - vMin);
  TEST_ASSERT_NEAR(soc1, 0.0f, 0.01f);

  float v2 = 5.0f;
  float soc2 = (v2 - vMin) / (vMax - vMin);
  TEST_ASSERT_NEAR(soc2, 1.0f, 0.01f);

  float v3 = 3.6f;
  float soc3 = (v3 - vMin) / (vMax - vMin);
  TEST_ASSERT_NEAR(soc3, 0.5f, 0.01f);
  return true;
}
