#include <math.h>
#include "sagitta_types.h"
#include "sagitta_messages.h"
#include "conductor_params.h"

/**
 * DynamicLineRatingP orchestrates the IEEE 738 dynamic line rating engine,
 * computes steady-state continuous ampacity, 15-minute emergency ampacity,
 * and maintains real-time thermal alert status.
 */
module DynamicLineRatingP {
  provides {
    interface DynamicLineRating;
  }
  uses {
    interface HeatBalance;
    interface JouleHeating;
    interface ConvectiveCooling;
    interface RadiativeCooling;
    interface SolarAbsorption;
    interface TransientThermal;
  }
}
implementation {
  const conductor_properties_t* m_conductor;
  msg_dlr_state_t m_state;
  uint16_t m_continuousAmpacity;
  uint16_t m_emergencyAmpacity15Min;
  bool m_isEvaluating;

  /* Pending evaluation inputs */
  uint16_t m_evalCurrentA;
  int16_t m_evalAmbientTempC;
  uint16_t m_evalWindSpeedMps;
  uint16_t m_evalWindYawDeg;
  uint16_t m_evalSolarFluxWm2;

  command error_t DynamicLineRating.configure(const conductor_properties_t* conductor) {
    if (!conductor) {
      return SAGITTA_ERROR_INVALID_ARG;
    }
    m_conductor = conductor;
    m_continuousAmpacity = 1000;
    m_emergencyAmpacity15Min = 1200;
    m_isEvaluating = FALSE;
    memset(&m_state, 0, sizeof(msg_dlr_state_t));
    m_state.header.magic = 0x53;
    m_state.header.msg_type = MSG_TYPE_DLR_STATE;
    return SAGITTA_SUCCESS;
  }

  task void computeDlrTask() {
    if (!m_conductor) {
      m_isEvaluating = FALSE;
      return;
    }

    float ambC = Q8_8_TO_FLOAT(m_evalAmbientTempC);
    float windMps = Q8_8_TO_FLOAT(m_evalWindSpeedMps);
    float windYaw = (float)m_evalWindYawDeg;
    float solarFlux = Q8_8_TO_FLOAT(m_evalSolarFluxWm2);
    float currA = (float)m_evalCurrentA;

    /* 1. Calculate equilibrium conductor temperature under current load */
    float coreTempC = ambC;
    call HeatBalance.solveEquilibriumTemp(
      m_conductor, ambC, windMps, windYaw, solarFlux, currA, &coreTempC);

    /* 2. Compute dynamic continuous ampacity for max allowable design temperature */
    float maxDesignTempC = m_conductor->max_allowable_temp_c;
    float qcMax = call ConvectiveCooling.computeConvectiveLoss(
      m_conductor->outer_diameter_m, maxDesignTempC, ambC, windMps, windYaw);
    float qrMax = call RadiativeCooling.computeRadiatedLoss(
      m_conductor->outer_diameter_m, m_conductor->emissivity, maxDesignTempC, ambC);
    float qs = call SolarAbsorption.computeSolarGain(
      m_conductor->outer_diameter_m, m_conductor->absorptivity, solarFlux, 90.0f);
    float rAtMax = call JouleHeating.computeResistance(m_conductor, maxDesignTempC);

    float netHeatCapacity = qcMax + qrMax - qs;
    if (netHeatCapacity > 0.0f && rAtMax > 0.0f) {
      m_continuousAmpacity = (uint16_t)sqrtf(netHeatCapacity / rAtMax);
    } else {
      m_continuousAmpacity = 100;
    }

    /* 3. Compute 15-minute emergency ampacity */
    float emergTempC = m_conductor->emergency_temp_c;
    float qcEmerg = call ConvectiveCooling.computeConvectiveLoss(
      m_conductor->outer_diameter_m, emergTempC, ambC, windMps, windYaw);
    float qrEmerg = call RadiativeCooling.computeRadiatedLoss(
      m_conductor->outer_diameter_m, m_conductor->emissivity, emergTempC, ambC);
    float rAtEmerg = call JouleHeating.computeResistance(m_conductor, emergTempC);

    float netEmergCapacity = qcEmerg + qrEmerg - qs;
    if (netEmergCapacity > 0.0f && rAtEmerg > 0.0f) {
      m_emergencyAmpacity15Min = (uint16_t)sqrtf(netEmergCapacity / rAtEmerg);
    } else {
      m_emergencyAmpacity15Min = m_continuousAmpacity;
    }

    /* 4. Update state payload */
    m_state.conductor_temp_c_q8 = FLOAT_TO_Q8_8(coreTempC);
    m_state.ambient_temp_c_q8 = m_evalAmbientTempC;
    m_state.wind_speed_mps_q8 = m_evalWindSpeedMps;
    m_state.wind_angle_deg_q8 = m_evalWindYawDeg;
    m_state.solar_flux_w_q8 = m_evalSolarFluxWm2;
    m_state.current_ampacity_a = m_continuousAmpacity;
    m_state.measured_current_a = m_evalCurrentA;

    if (m_continuousAmpacity > 0) {
      uint32_t pct = ((uint32_t)m_evalCurrentA * 100) / m_continuousAmpacity;
      m_state.thermal_capacity_pct = (pct > 255) ? 255 : (uint8_t)pct;
    } else {
      m_state.thermal_capacity_pct = 100;
    }

    /* Check alarm thresholds */
    if (coreTempC >= m_conductor->emergency_temp_c) {
      m_state.alarm_state = ALARM_LEVEL_EMERGENCY;
      signal DynamicLineRating.thermalAlarm((int16_t)coreTempC, (int16_t)m_conductor->emergency_temp_c, ALARM_LEVEL_EMERGENCY);
    } else if (coreTempC >= m_conductor->max_allowable_temp_c) {
      m_state.alarm_state = ALARM_LEVEL_CRITICAL;
      signal DynamicLineRating.thermalAlarm((int16_t)coreTempC, (int16_t)m_conductor->max_allowable_temp_c, ALARM_LEVEL_CRITICAL);
    } else if (coreTempC >= m_conductor->max_allowable_temp_c - 10.0f) {
      m_state.alarm_state = ALARM_LEVEL_WARNING;
      signal DynamicLineRating.thermalAlarm((int16_t)coreTempC, (int16_t)m_conductor->max_allowable_temp_c, ALARM_LEVEL_WARNING);
    } else {
      m_state.alarm_state = ALARM_LEVEL_NORMAL;
    }

    m_isEvaluating = FALSE;
    signal DynamicLineRating.ratingUpdated(&m_state);
  }

  command error_t DynamicLineRating.evaluateRating(
    uint16_t currentA,
    int16_t ambientTempC,
    uint16_t windSpeedMps,
    uint16_t windYawDeg,
    uint16_t solarFluxWm2
  ) {
    if (m_isEvaluating) {
      return SAGITTA_ERROR_BUSY;
    }
    m_isEvaluating = TRUE;
    m_evalCurrentA = currentA;
    m_evalAmbientTempC = ambientTempC;
    m_evalWindSpeedMps = windSpeedMps;
    m_evalWindYawDeg = windYawDeg;
    m_evalSolarFluxWm2 = solarFluxWm2;

    post computeDlrTask();
    return SAGITTA_SUCCESS;
  }

  command uint16_t DynamicLineRating.getContinuousAmpacity() {
    return m_continuousAmpacity;
  }

  command uint16_t DynamicLineRating.getEmergencyAmpacity(uint8_t durationMinutes) {
    if (durationMinutes <= 15) {
      return m_emergencyAmpacity15Min;
    }
    return m_continuousAmpacity;
  }
}
