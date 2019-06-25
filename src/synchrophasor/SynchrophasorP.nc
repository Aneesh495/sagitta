#include <math.h>
#include "sagitta_types.h"
#include "sagitta_config.h"
#include "phasor_params.h"
#include "sagitta_messages.h"

/**
 * SynchrophasorP manages instantaneous voltage/current ADC sample streaming,
 * DFT phasor synthesis, frequency tracking, and IEEE C37.118 frame formatting.
 */
module SynchrophasorP {
  provides {
    interface Synchrophasor;
  }
  uses {
    interface DftPhasor;
    interface FrequencyEstimator;
    interface RocofMonitor;
  }
}
implementation {
  synchrophasor_config_t m_config;
  int16_t m_vSamples[SYNCHROPHASOR_DFT_WINDOW];
  int16_t m_iSamples[SYNCHROPHASOR_DFT_WINDOW];
  uint16_t m_sampleIndex;

  int32_t m_dftRealV;
  int32_t m_dftImagV;
  int32_t m_dftRealI;
  int32_t m_dftImagI;

  msg_synchrophasor_t m_frame;
  sagitta_timestamp_t m_lastTimestamp;

  command error_t Synchrophasor.configure(const synchrophasor_config_t* config) {
    if (!config) {
      return SAGITTA_ERROR_INVALID_ARG;
    }
    memcpy(&m_config, config, sizeof(synchrophasor_config_t));
    m_sampleIndex = 0;
    m_dftRealV = 0;
    m_dftImagV = 0;
    m_dftRealI = 0;
    m_dftImagI = 0;
    memset(m_vSamples, 0, sizeof(m_vSamples));
    memset(m_iSamples, 0, sizeof(m_iSamples));

    memset(&m_frame, 0, sizeof(msg_synchrophasor_t));
    m_frame.header.magic = 0x53;
    m_frame.header.msg_type = MSG_TYPE_SYNCHROPHASOR;

    call DftPhasor.initDft(SYNCHROPHASOR_DFT_WINDOW);
    return SAGITTA_SUCCESS;
  }

  command error_t Synchrophasor.pushSamplePair(
    int16_t rawVoltageSample,
    int16_t rawCurrentSample,
    const sagitta_timestamp_t* timestamp
  ) {
    uint16_t oldestIndex = (m_sampleIndex + 1) % SYNCHROPHASOR_DFT_WINDOW;
    int16_t oldV = m_vSamples[oldestIndex];
    int16_t oldI = m_iSamples[oldestIndex];

    m_vSamples[m_sampleIndex] = rawVoltageSample;
    m_iSamples[m_sampleIndex] = rawCurrentSample;
    m_sampleIndex = (m_sampleIndex + 1) % SYNCHROPHASOR_DFT_WINDOW;

    /* Update recursive DFT */
    call DftPhasor.updateRecursiveDft(rawVoltageSample, oldV, &m_dftRealV, &m_dftImagV);
    call DftPhasor.updateRecursiveDft(rawCurrentSample, oldI, &m_dftRealI, &m_dftImagI);

    if (m_sampleIndex == 0) {
      /* Full cycle complete, emit synchrophasor frame */
      float vMagRms = 0.0f;
      float vPhaseRad = 0.0f;
      float iMagRms = 0.0f;
      float iPhaseRad = 0.0f;

      call DftPhasor.computeMagnitudeAndPhase(m_dftRealV, m_dftImagV, &vMagRms, &vPhaseRad);
      call DftPhasor.computeMagnitudeAndPhase(m_dftRealI, m_dftImagI, &iMagRms, &iPhaseRad);

      float dt = 1.0f / 60.0f;
      float freqHz = call FrequencyEstimator.updateFrequency(vPhaseRad, dt);
      float rocof = call RocofMonitor.updateRocof(freqHz, timestamp ? timestamp->microseconds : 0);

      m_frame.v_mag_rms_mv = (uint32_t)(vMagRms * m_config.voltage_ratio_divider);
      m_frame.v_phase_rad_q15 = FLOAT_TO_Q15(vPhaseRad / 3.14159265f);
      m_frame.i_mag_rms_ma = (uint32_t)(iMagRms * m_config.current_ratio_ct);
      m_frame.i_phase_rad_q15 = FLOAT_TO_Q15(iPhaseRad / 3.14159265f);
      m_frame.frequency_mhz = (uint16_t)(freqHz * 1000.0f);
      m_frame.rocof_mhz_per_s = (int16_t)(rocof * 1000.0f);
      m_frame.status_flags = 0x0000; /* Good data, synchronized to UTC */

      if (timestamp) {
        m_frame.header.timestamp_s = timestamp->seconds;
        m_frame.header.timestamp_us = timestamp->microseconds;
      }

      signal Synchrophasor.phasorFrameReady(&m_frame);
    }

    return SAGITTA_SUCCESS;
  }
}
