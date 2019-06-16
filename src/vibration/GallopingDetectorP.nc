#include <math.h>
#include "sagitta_types.h"
#include "vibration_params.h"

/**
 * GallopingDetectorP detects low-frequency large-amplitude subconductor galloping.
 */
module GallopingDetectorP {
  provides {
    interface GallopingDetector;
  }
}
implementation {
  command error_t GallopingDetector.checkGallopingCondition(
    const vibration_parameters_t* params,
    float dominantFreqHz,
    float peakToPeakDisplacementM,
    bool* isGallopingOut
  ) {
    if (!params || !isGallopingOut) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    /* Galloping frequency range is typically 0.1 Hz to 2.0 Hz */
    bool inFreqBand = (dominantFreqHz >= params->galloping_freq_low_hz) &&
                      (dominantFreqHz <= params->galloping_freq_high_hz);

    /* Amplitude threshold (typically > 0.2 m peak-to-peak) */
    bool exceedsAmp = (peakToPeakDisplacementM >= params->galloping_min_amp_m);

    bool gallopingActive = inFreqBand && exceedsAmp;
    *isGallopingOut = gallopingActive;

    if (gallopingActive) {
      alarm_level_t severity = ALARM_LEVEL_WARNING;
      if (peakToPeakDisplacementM >= 1.0f) {
        severity = ALARM_LEVEL_EMERGENCY;
      } else if (peakToPeakDisplacementM >= 0.5f) {
        severity = ALARM_LEVEL_CRITICAL;
      }
      signal GallopingDetector.gallopingDetected(dominantFreqHz, peakToPeakDisplacementM, severity);
    }

    return SAGITTA_SUCCESS;
  }
}
