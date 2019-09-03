#include "sagitta_types.h"

/**
 * MedianFilterP implements a 5-point running median filter for removing
 * impulsive spike artifacts from analog sensor lines.
 */
module MedianFilterP {
  provides {
    interface DigitalFilter as Median;
  }
}
implementation {
  int16_t m_samples[5];
  uint8_t m_idx;
  uint8_t m_filled;

  command void Median.resetFilter() {
    memset(m_samples, 0, sizeof(m_samples));
    m_idx = 0;
    m_filled = 0;
  }

  command q15_t Median.filterSample(q15_t inputSample) {
    m_samples[m_idx] = inputSample;
    m_idx = (m_idx + 1) % 5;
    if (m_filled < 5) m_filled++;

    if (m_filled < 3) return inputSample;

    /* Sort temporary copy of window */
    int16_t sorted[5];
    memcpy(sorted, m_samples, m_filled * sizeof(int16_t));
    for (uint8_t i = 0; i < m_filled - 1; i++) {
      for (uint8_t j = i + 1; j < m_filled; j++) {
        if (sorted[i] > sorted[j]) {
          int16_t tmp = sorted[i];
          sorted[i] = sorted[j];
          sorted[j] = tmp;
        }
      }
    }

    return sorted[m_filled / 2];
  }

  command void Median.filterBlock(q15_t* buffer, uint16_t count) {
    if (!buffer) return;
    for (uint16_t i = 0; i < count; i++) {
      buffer[i] = call Median.filterSample(buffer[i]);
    }
  }
}
