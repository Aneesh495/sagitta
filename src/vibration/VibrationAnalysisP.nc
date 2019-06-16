#include <math.h>
#include "sagitta_types.h"
#include "sagitta_config.h"
#include "vibration_params.h"
#include "conductor_params.h"

/**
 * VibrationAnalysisP manages the inertial sample buffer, triggers the FFT
 * transformation, identifies resonance peaks, and computes fatigue metrics.
 */
module VibrationAnalysisP {
  provides {
    interface VibrationAnalysis;
  }
  uses {
    interface FastFourierTransform;
    interface ModalBending;
    interface GallopingDetector;
    interface FatigueLife;
  }
}
implementation {
  vibration_parameters_t m_params;
  q15_t m_realBuffer[VIBRATION_FFT_SIZE];
  q15_t m_imagBuffer[VIBRATION_FFT_SIZE];
  uint32_t m_powerBuffer[VIBRATION_FFT_SIZE / 2];

  uint16_t m_sampleIndex;
  bool m_isProcessing;
  msg_vibration_alert_t m_alert;

  command error_t VibrationAnalysis.configure(const vibration_parameters_t* params) {
    if (!params) {
      return SAGITTA_ERROR_INVALID_ARG;
    }
    memcpy(&m_params, params, sizeof(vibration_parameters_t));
    m_sampleIndex = 0;
    m_isProcessing = FALSE;
    memset(&m_alert, 0, sizeof(msg_vibration_alert_t));
    m_alert.header.magic = 0x53;
    m_alert.header.msg_type = MSG_TYPE_VIBRATION_ALERT;
    return SAGITTA_SUCCESS;
  }

  command error_t VibrationAnalysis.pushSamples(const int16_t* accelSamples, uint16_t sampleCount) {
    if (!accelSamples) {
      return SAGITTA_ERROR_INVALID_ARG;
    }
    for (uint16_t i = 0; i < sampleCount; i++) {
      if (m_sampleIndex < VIBRATION_FFT_SIZE) {
        m_realBuffer[m_sampleIndex++] = (q15_t)accelSamples[i];
      }
    }
    return SAGITTA_SUCCESS;
  }

  task void processVibrationTask() {
    /* Clear imaginary component */
    memset(m_imagBuffer, 0, sizeof(m_imagBuffer));

    /* 1. Apply Hann window */
    call FastFourierTransform.applyHannWindow(m_realBuffer, VIBRATION_FFT_SIZE);

    /* 2. Compute in-place Radix-2 FFT */
    call FastFourierTransform.transformRadix2(m_realBuffer, m_imagBuffer, VIBRATION_FFT_SIZE);

    /* 3. Compute power spectrum */
    call FastFourierTransform.computePowerSpectrum(
      m_realBuffer, m_imagBuffer, m_powerBuffer, VIBRATION_FFT_SIZE);

    /* 4. Find dominant resonance peak */
    float peakFreqHz = 0.0f;
    uint32_t peakPower = 0;
    call FastFourierTransform.findPeakFrequency(
      m_powerBuffer, VIBRATION_FFT_SIZE / 2, (float)VIBRATION_SAMPLE_RATE_HZ,
      &peakFreqHz, &peakPower);

    /* Estimate peak acceleration in g units from spectral power */
    float peakAccelG = sqrtf((float)peakPower) / 32768.0f;

    /* 5. Compute modal bending strain at clamp */
    float bendingAmpUm = 0.0f;
    float microstrain = 0.0f;
    conductor_properties_t defaultConductor = {
      .outer_diameter_m = 0.02814f,
      .linear_weight_n_per_m = 15.96f
    };

    call ModalBending.computeBendingStrain(
      &defaultConductor, &m_params, peakAccelG, peakFreqHz, 25000.0f,
      &bendingAmpUm, &microstrain);

    /* 6. Accumulate fatigue cycle damage */
    uint32_t cyclesInWindow = (uint32_t)(peakFreqHz * ((float)VIBRATION_FFT_SIZE / (float)VIBRATION_SAMPLE_RATE_HZ));
    float totalDamage = 0.0f;
    call FatigueLife.accumulateCycleDamage(&m_params, microstrain, cyclesInWindow, &totalDamage);

    /* 7. Check subconductor galloping */
    bool isGalloping = FALSE;
    float peakDisplacementM = (bendingAmpUm * 1e-6f);
    call GallopingDetector.checkGallopingCondition(
      &m_params, peakFreqHz, peakDisplacementM, &isGalloping);

    /* 8. Populate alert record */
    m_alert.dominant_freq_hz_q8 = FLOAT_TO_Q8_8(peakFreqHz);
    m_alert.bending_amp_um = (uint16_t)bendingAmpUm;
    m_alert.bending_strain_ue = (uint16_t)microstrain;
    m_alert.fatigue_cycles_accum = (uint32_t)(totalDamage * 1e6f);
    m_alert.galloping_detected = isGalloping ? 1 : 0;

    if (isGalloping || microstrain > 300.0f) {
      m_alert.severity = ALARM_LEVEL_CRITICAL;
    } else if (microstrain > 150.0f) {
      m_alert.severity = ALARM_LEVEL_WARNING;
    } else {
      m_alert.severity = ALARM_LEVEL_NORMAL;
    }

    /* Reset buffer pointer */
    m_sampleIndex = 0;
    m_isProcessing = FALSE;

    signal VibrationAnalysis.analysisComplete(&m_alert);
  }

  command error_t VibrationAnalysis.processSpectrum() {
    if (m_isProcessing) {
      return SAGITTA_ERROR_BUSY;
    }
    m_isProcessing = TRUE;
    post processVibrationTask();
    return SAGITTA_SUCCESS;
  }
}
