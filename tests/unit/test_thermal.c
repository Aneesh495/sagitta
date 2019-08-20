#include <stdio.h>
#include <math.h>
#include "../test_runner.h"
#include "../../src/include/sagitta_types.h"
#include "../../src/include/conductor_params.h"

/* Convective cooling formula validation in SI units */
static float calc_convective(float d, float tc, float ta, float v, float yaw) {
  float deltaT = tc - ta;
  if (deltaT <= 0.0f) return 0.0f;
  float film = (tc + ta) * 0.5f;
  float kf = 2.424e-2f + 7.477e-5f * film;
  float rho = 1.293f * (273.15f / (film + 273.15f));
  float mu = 1.8e-5f;
  float re = (d * rho * v) / mu;

  float rad = fabsf(yaw) * (3.14159265f / 180.0f);
  float kAngle = 1.194f - cosf(rad) + 0.194f * cosf(2.0f * rad) + 0.368f * sinf(2.0f * rad);
  if (kAngle < 0.2f) kAngle = 0.2f;

  float qc1 = (1.01f + 1.35f * powf(re, 0.52f)) * kf * deltaT * kAngle;
  float qc2 = (0.754f * powf(re, 0.6f)) * kf * deltaT * kAngle;
  float qcn = 3.645f * powf(rho, 0.5f) * powf(d, 0.75f) * powf(deltaT, 1.25f);

  float qcForced = (qc1 > qc2) ? qc1 : qc2;
  return (qcForced > qcn) ? qcForced : qcn;
}

static float calc_radiative(float d, float eps, float tc, float ta) {
  if (tc <= ta) return 0.0f;
  float tcRatio = (tc + 273.15f) / 100.0f;
  float taRatio = (ta + 273.15f) / 100.0f;
  return 17.8f * d * eps * (powf(tcRatio, 4.0f) - powf(taRatio, 4.0f));
}

static float calc_joule(float i, float rRef, float alpha, float tc) {
  float r = rRef * (1.0f + alpha * (tc - 20.0f));
  return i * i * r;
}

bool test_convective_cooling_forced(void) {
  float d = 0.02814f; /* ACSR Drake 795 kcmil */
  float tc = 75.0f;
  float ta = 25.0f;
  float v = 2.0f;
  float yaw = 90.0f; /* Perpendicular wind */

  float qc = calc_convective(d, tc, ta, v, yaw);
  TEST_ASSERT(qc > 100.0f && qc < 160.0f); /* Typical range: 130-145 W/m */
  return true;
}

bool test_convective_cooling_natural(void) {
  float d = 0.02814f;
  float tc = 75.0f;
  float ta = 25.0f;
  float v = 0.0f; /* Zero wind */
  float yaw = 0.0f;

  float qc = calc_convective(d, tc, ta, v, yaw);
  TEST_ASSERT(qc > 25.0f && qc < 50.0f); /* Natural convection rate: ~34.8 W/m */
  return true;
}

bool test_radiative_cooling_stefan_boltzmann(void) {
  float d = 0.02814f;
  float eps = 0.8f;
  float tc = 75.0f;
  float ta = 25.0f;

  float qr = calc_radiative(d, eps, tc, ta);
  TEST_ASSERT(qr > 20.0f && qr < 35.0f); /* Radiative dissipation rate: ~27.2 W/m */
  return true;
}

bool test_joule_heating_temperature_adjusted(void) {
  float i = 1000.0f; /* 1000 Amperes */
  float rRef = 7.28e-5f; /* Ohm/m at 20 C */
  float alpha = 0.0039f;

  float qj20 = calc_joule(i, rRef, alpha, 20.0f);
  float qj75 = calc_joule(i, rRef, alpha, 75.0f);

  TEST_ASSERT_NEAR(qj20, 72.8f, 0.5f);
  TEST_ASSERT(qj75 > qj20); /* Resistance rises with temperature */
  TEST_ASSERT_NEAR(qj75, 72.8f * (1.0f + 0.0039f * 55.0f), 1.0f);
  return true;
}

bool test_dynamic_ampacity_convergence(void) {
  float d = 0.02814f;
  float eps = 0.8f;
  float rRef = 7.28e-5f;
  float alpha = 0.0039f;
  float tcMax = 75.0f;
  float ta = 25.0f;
  float v = 1.0f;
  float yaw = 90.0f;
  float qs = 0.8f * 900.0f * d; /* Solar gain: ~20.2 W/m */

  float qc = calc_convective(d, tcMax, ta, v, yaw);
  float qr = calc_radiative(d, eps, tcMax, ta);
  float rAtMax = rRef * (1.0f + alpha * (tcMax - 20.0f));

  float netHeat = qc + qr - qs;
  TEST_ASSERT(netHeat > 0.0f);

  float ampacity = sqrtf(netHeat / rAtMax);
  TEST_ASSERT(ampacity > 800.0f && ampacity < 1600.0f);
  return true;
}
