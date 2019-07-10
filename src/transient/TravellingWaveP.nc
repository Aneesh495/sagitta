#include "sagitta_types.h"
#include "wavefront_params.h"
#include "sagitta_messages.h"

/**
 * TravellingWaveP coordinates wavefront comparator arming, event detection,
 * classification, and over-the-air fault reporting.
 */
module TravellingWaveP {
  provides {
    interface TravellingWave;
  }
  uses {
    interface WavefrontCapture;
    interface DoubleEndedTwfl;
    interface BewleyLattice;
    interface SurgeClassifier;
  }
}
implementation {
  wavefront_config_t m_config;
  msg_wavefront_event_t m_event;
  bool m_isArmed;

  command error_t TravellingWave.configure(const wavefront_config_t* config) {
    if (!config) {
      return SAGITTA_ERROR_INVALID_ARG;
    }
    memcpy(&m_config, config, sizeof(wavefront_config_t));
    m_isArmed = FALSE;

    memset(&m_event, 0, sizeof(msg_wavefront_event_t));
    m_event.header.magic = 0x53;
    m_event.header.msg_type = MSG_TYPE_WAVEFRONT_EVENT;
    return SAGITTA_SUCCESS;
  }

  command error_t TravellingWave.armWavefrontTrigger() {
    m_isArmed = TRUE;
    return SAGITTA_SUCCESS;
  }

  task void processWavefrontEventTask() {
    uint16_t peakMv = call WavefrontCapture.getPeakSurgeMilliVolts();
    uint16_t riseNs = call WavefrontCapture.getRiseTimeNanoseconds();
    uint8_t surgeClass = call SurgeClassifier.classifySurge(riseNs, peakMv, 50);

    m_event.wavefront_peak_mv = peakMv;
    m_event.risetime_ns = riseNs;
    m_event.polarity = 1; /* Positive surge */
    m_event.surge_classification = surgeClass;
    m_event.span_identifier = 12; /* Detected on span #12 */

    signal TravellingWave.wavefrontCaptured(&m_event);
  }
}
