#include <math.h>
#include "sagitta_types.h"
#include "sagitta_config.h"

/**
 * FastFourierTransformP implements an in-place Radix-2 Decimation-In-Time FFT
 * optimized for embedded microcontrollers without floating-point acceleration.
 */
module FastFourierTransformP {
  provides {
    interface FastFourierTransform;
  }
}
implementation {

  /* Bit reversal index calculation for N-point FFT */
  static uint16_t reverseBits(uint16_t x, uint8_t bits) {
    uint16_t reversed = 0;
    for (uint8_t i = 0; i < bits; i++) {
      if (x & (1 << i)) {
        reversed |= (1 << (bits - 1 - i));
      }
    }
    return reversed;
  }

  command void FastFourierTransform.applyHannWindow(q15_t* realBuffer, uint16_t length) {
    if (!realBuffer || length == 0) {
      return;
    }
    float nMinus1 = (float)(length - 1);
    for (uint16_t i = 0; i < length; i++) {
      /* Hann window: w[n] = 0.5 * (1 - cos(2*pi*n / (N-1))) */
      float w = 0.5f * (1.0f - cosf((2.0f * 3.14159265f * (float)i) / nMinus1));
      float val = Q15_TO_FLOAT(realBuffer[i]);
      realBuffer[i] = FLOAT_TO_Q15(val * w);
    }
  }

  command error_t FastFourierTransform.transformRadix2(q15_t* realBuffer, q15_t* imagBuffer, uint16_t length) {
    if (!realBuffer || !imagBuffer || (length & (length - 1)) != 0 || length == 0) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    /* Compute number of stages: log2(length) */
    uint8_t stages = 0;
    uint16_t temp = length;
    while (temp > 1) {
      stages++;
      temp >>= 1;
    }

    /* Bit-reversal permutation */
    for (uint16_t i = 0; i < length; i++) {
      uint16_t j = reverseBits(i, stages);
      if (j > i) {
        q15_t tempR = realBuffer[i];
        realBuffer[i] = realBuffer[j];
        realBuffer[j] = tempR;

        q15_t tempI = imagBuffer[i];
        imagBuffer[i] = imagBuffer[j];
        imagBuffer[j] = tempI;
      }
    }

    /* Cooley-Tukey Radix-2 butterfly computation */
    for (uint8_t s = 1; s <= stages; s++) {
      uint16_t m = 1 << s;       /* Butterfly group length */
      uint16_t mHalf = m >> 1;   /* Distance between butterfly legs */
      float thetaStep = -2.0f * 3.14159265f / (float)m;

      for (uint16_t k = 0; k < length; k += m) {
        for (uint16_t j = 0; j < mHalf; j++) {
          float angle = thetaStep * (float)j;
          float cosVal = cosf(angle);
          float sinVal = sinf(angle);

          uint16_t uIndex = k + j;
          uint16_t vIndex = k + j + mHalf;

          float vr = Q15_TO_FLOAT(realBuffer[vIndex]);
          float vi = Q15_TO_FLOAT(imagBuffer[vIndex]);

          /* Complex twiddle multiplication: W * V */
          float twiddleR = vr * cosVal - vi * sinVal;
          float twiddleI = vr * sinVal + vi * cosVal;

          float ur = Q15_TO_FLOAT(realBuffer[uIndex]);
          float ui = Q15_TO_FLOAT(imagBuffer[uIndex]);

          /* Butterfly combination with 0.5 scaling to prevent overflow */
          realBuffer[uIndex] = FLOAT_TO_Q15((ur + twiddleR) * 0.5f);
          imagBuffer[uIndex] = FLOAT_TO_Q15((ui + twiddleI) * 0.5f);

          realBuffer[vIndex] = FLOAT_TO_Q15((ur - twiddleR) * 0.5f);
          imagBuffer[vIndex] = FLOAT_TO_Q15((ui - twiddleI) * 0.5f);
        }
      }
    }

    return SAGITTA_SUCCESS;
  }

  command void FastFourierTransform.computePowerSpectrum(
    const q15_t* realBuffer,
    const q15_t* imagBuffer,
    uint32_t* powerOut,
    uint16_t length
  ) {
    if (!realBuffer || !imagBuffer || !powerOut) {
      return;
    }
    uint16_t half = length >> 1;
    for (uint16_t i = 0; i < half; i++) {
      int32_t r = (int32_t)realBuffer[i];
      int32_t im = (int32_t)imagBuffer[i];
      powerOut[i] = (uint32_t)(r * r + im * im);
    }
  }

  command void FastFourierTransform.findPeakFrequency(
    const uint32_t* powerSpectrum,
    uint16_t numBins,
    float sampleRateHz,
    float* peakFreqHzOut,
    uint32_t* peakPowerOut
  ) {
    if (!powerSpectrum || !peakFreqHzOut || !peakPowerOut || numBins == 0) {
      return;
    }

    /* Ignore DC bin index 0 to avoid offset bias */
    uint16_t peakIndex = 1;
    uint32_t maxPower = powerSpectrum[1];

    for (uint16_t i = 2; i < numBins; i++) {
      if (powerSpectrum[i] > maxPower) {
        maxPower = powerSpectrum[i];
        peakIndex = i;
      }
    }

    float binResolution = sampleRateHz / (float)(numBins * 2);
    *peakFreqHzOut = (float)peakIndex * binResolution;
    *peakPowerOut = maxPower;
  }
}
