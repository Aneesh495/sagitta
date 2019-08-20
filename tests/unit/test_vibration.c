#include <stdio.h>
#include <string.h>
#include <math.h>
#include "../test_runner.h"
#include "../../src/include/sagitta_types.h"

static uint16_t reverse_bits(uint16_t x, uint8_t bits) {
  uint16_t rev = 0;
  for (uint8_t i = 0; i < bits; i++) {
    if (x & (1 << i)) rev |= (1 << (bits - 1 - i));
  }
  return rev;
}

static void fft_radix2_float(float* real, float* imag, uint16_t n) {
  uint8_t stages = 0;
  uint16_t temp = n;
  while (temp > 1) { stages++; temp >>= 1; }

  for (uint16_t i = 0; i < n; i++) {
    uint16_t j = reverse_bits(i, stages);
    if (j > i) {
      float tr = real[i]; real[i] = real[j]; real[j] = tr;
      float ti = imag[i]; imag[i] = imag[j]; imag[j] = ti;
    }
  }

  for (uint8_t s = 1; s <= stages; s++) {
    uint16_t m = 1 << s;
    uint16_t mHalf = m >> 1;
    float thetaStep = -2.0f * 3.14159265f / (float)m;

    for (uint16_t k = 0; k < n; k += m) {
      for (uint16_t j = 0; j < mHalf; j++) {
        float angle = thetaStep * (float)j;
        float cosVal = cosf(angle);
        float sinVal = sinf(angle);

        uint16_t u = k + j;
        uint16_t v = k + j + mHalf;

        float vr = real[v];
        float vi = imag[v];
        float twiddleR = vr * cosVal - vi * sinVal;
        float twiddleI = vr * sinVal + vi * cosVal;

        float ur = real[u];
        float ui = imag[u];

        real[u] = ur + twiddleR;
        imag[u] = ui + twiddleI;
        real[v] = ur - twiddleR;
        imag[v] = ui - twiddleI;
      }
    }
  }
}

bool test_fft_spectral_peak_identification(void) {
  uint16_t n = 256;
  float sampleRate = 256.0f;
  float targetFreq = 24.0f; /* 24 Hz synthetic vibration */
  float real[256];
  float imag[256];
  memset(imag, 0, sizeof(imag));

  for (uint16_t i = 0; i < n; i++) {
    float t = (float)i / sampleRate;
    real[i] = sinf(2.0f * 3.14159265f * targetFreq * t);
  }

  fft_radix2_float(real, imag, n);

  /* Find peak power */
  uint16_t peakBin = 1;
  float maxPower = 0.0f;
  for (uint16_t i = 1; i < n / 2; i++) {
    float power = real[i] * real[i] + imag[i] * imag[i];
    if (power > maxPower) {
      maxPower = power;
      peakBin = i;
    }
  }

  float binRes = sampleRate / (float)n;
  float detectedFreq = (float)peakBin * binRes;

  TEST_ASSERT_NEAR(detectedFreq, targetFreq, 1.0f);
  return true;
}

bool test_karman_vortex_shedding_frequency(void) {
  float st = 0.19f;
  float d = 0.02814f;
  float v = 4.0f; /* 4 m/s wind */

  /* f_s = St * V / D */
  float fs = (st * v) / d;
  /* (0.19 * 4.0) / 0.02814 = 27.007 Hz */
  TEST_ASSERT_NEAR(fs, 27.0f, 0.5f);
  return true;
}

bool test_poffenberger_swart_bending_strain(void) {
  float d = 0.02814f;
  float h = 25000.0f;
  float ei = 500.0f;
  float xb = 0.089f;
  float ybM = 0.00010f; /* 100 um peak-to-peak displacement */

  float p = sqrtf(h / ei); /* sqrt(25000 / 500) = sqrt(50) ~ 7.071 */
  float pXb = p * xb;
  float denom = expf(-pXb) - 1.0f + pXb;

  float strain = (d * p * p * ybM) / (4.0f * denom);
  float microstrain = strain * 1e6f;

  TEST_ASSERT(microstrain > 50.0f && microstrain < 400.0f);
  return true;
}

bool test_palmgren_miner_fatigue_accumulation(void) {
  float c = 1e18f;
  float m = 4.5f;
  float microstrain = 200.0f;
  uint32_t cycles = 100000;

  float nAllow = c * powf(microstrain, -m);
  float damage = (float)cycles / nAllow;

  TEST_ASSERT(damage > 0.0f);
  TEST_ASSERT(damage < 1.0f); /* Safe below fatigue limit */
  return true;
}
