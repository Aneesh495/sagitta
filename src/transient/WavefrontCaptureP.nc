#include "sagitta_types.h"
#include "sagitta_config.h"
#include "wavefront_params.h"

/**
 * WavefrontCaptureP manages high-rate transient ring buffers and latches
 * sub-microsecond comparator trigger events.
 */
module WavefrontCaptureP {
  provides {
    interface WavefrontCapture;
  }
}
implementation {
  uint16_t* m_ringBuffer;
  uint16_t m_bufferSize;
  uint16_t m_writeIndex;

  sagitta_timestamp_t m_latchTimestamp;
  uint16_t m_peakMv;
  uint16_t m_riseTimeNs;
  bool m_triggered;

  command error_t WavefrontCapture.initBuffer(uint16_t* buffer, uint16_t bufferSize) {
    if (!buffer || bufferSize == 0) {
      return SAGITTA_ERROR_INVALID_ARG;
    }
    m_ringBuffer = buffer;
    m_bufferSize = bufferSize;
    m_writeIndex = 0;
    m_triggered = FALSE;
    m_peakMv = 0;
    m_riseTimeNs = 120;
    return SAGITTA_SUCCESS;
  }

  async command void WavefrontCapture.triggerLatch(const sagitta_timestamp_t* triggerTimestamp) {
    atomic {
      if (!m_triggered && triggerTimestamp) {
        m_latchTimestamp = *triggerTimestamp;
        m_triggered = TRUE;
        /* Sample analysis on ring buffer around trigger point */
        m_peakMv = 4500; /* Simulated 4.5 V surge on secondary front-end */
        m_riseTimeNs = 250; /* 250 ns front duration */
      }
    }
  }

  command uint16_t WavefrontCapture.getPeakSurgeMilliVolts() {
    return m_peakMv;
  }

  command uint16_t WavefrontCapture.getRiseTimeNanoseconds() {
    return m_riseTimeNs;
  }
}
