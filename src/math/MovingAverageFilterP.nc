#include "sagitta_types.h"

#define MOVING_AVG_WINDOW_SIZE 16

/**
 * MovingAverageFilterP implements an O(1) circular window boxcar average filter.
 */
module MovingAverageFilterP {
  provides {
    interface DigitalFilter as MovingAverage;
  }
}
implementation {
  int16_t m_window[MOVING_AVG_WINDOW_SIZE];
  int32_t m_runningSum;
  uint8_t m_head;
  uint8_t m_count;

  command void MovingAverage.resetFilter() {
    memset(m_window, 0, sizeof(m_window));
    m_runningSum = 0;
    m_head = 0;
    m_count = 0;
  }

  command q15_t MovingAverage.filterSample(q15_t inputSample) {
    if (m_count < MOVING_AVG_WINDOW_SIZE) {
      m_window[m_head] = inputSample;
      m_runningSum += inputSample;
      m_head = (m_head + 1) % MOVING_AVG_WINDOW_SIZE;
      m_count++;
      return (q15_t)(m_runningSum / m_count);
    } else {
      m_runningSum -= m_window[m_head];
      m_window[m_head] = inputSample;
      m_runningSum += inputSample;
      m_head = (m_head + 1) % MOVING_AVG_WINDOW_SIZE;
      return (q15_t)(m_runningSum >> 4); /* Divide by 16 */
    }
  }

  command void MovingAverage.filterBlock(q15_t* buffer, uint16_t count) {
    if (!buffer) return;
    for (uint16_t i = 0; i < count; i++) {
      buffer[i] = call MovingAverage.filterSample(buffer[i]);
    }
  }
}
