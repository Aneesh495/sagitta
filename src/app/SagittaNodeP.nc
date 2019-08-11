#include "sagitta_types.h"
#include "sagitta_config.h"
#include "sagitta_messages.h"
#include "conductor_params.h"
#include "catenary_params.h"
#include "vibration_params.h"
#include "power_params.h"

/**
 * SagittaNodeP coordinates all subsystem activities on a transmission line mote:
 * evaluates DLR, samples catenary tilt, triggers vibration FFTs, manages power
 * modes, and telemeters state frames along the corridor.
 */
module SagittaNodeP {
  provides {
    interface Init;
  }
  uses {
    interface DynamicLineRating;
    interface CatenarySag;
    interface TiltToSag;
    interface GroundClearance;
    interface IceAccretion;
    interface VibrationAnalysis;
    interface Synchrophasor;
    interface TravellingWave;
    interface EnergyHarvest;
    interface MacTsch;
    interface TimeSync;
    interface CorridorRouting;
    interface WatchdogSuper;
  }
}
implementation {
  uint16_t m_nodeId;
  uint16_t m_spanId;
  span_geometry_t m_spanGeometry;
  conductor_properties_t m_conductorProps;

  command error_t Init.init() {
    m_nodeId = 12;
    m_spanId = 12;

    /* Initialize conductor: ACSR 795 Drake */
    m_conductorProps.name = "ACSR_Drake_795";
    m_conductorProps.outer_diameter_m = 0.02814f;
    m_conductorProps.linear_weight_n_per_m = 15.96f;
    m_conductorProps.resistance_ref_ohm_per_m = 7.28e-5f;
    m_conductorProps.temp_coeff_resistance = 0.0039f;
    m_conductorProps.mass_kg_per_m = 1.628f;
    m_conductorProps.specific_heat_j_kg_k = 950.0f;
    m_conductorProps.emissivity = 0.8f;
    m_conductorProps.absorptivity = 0.8f;
    m_conductorProps.elastic_modulus_pa = 7.7e10f;
    m_conductorProps.thermal_expansion_coeff = 1.89e-5f;
    m_conductorProps.max_allowable_temp_c = 75.0f;
    m_conductorProps.emergency_temp_c = 100.0f;

    /* Initialize span geometry */
    m_spanGeometry.span_id = m_spanId;
    m_spanGeometry.span_length_m = DEFAULT_SPAN_LENGTH_M;
    m_spanGeometry.tower_height_left_m = 35.0f;
    m_spanGeometry.tower_height_right_m = 35.0f;
    m_spanGeometry.mote_offset_from_tower_m = 2.0f;
    m_spanGeometry.design_horizontal_tension_n = 25000.0f;
    m_spanGeometry.statutory_clearance_m = DEFAULT_STATUTORY_CLEARANCE_M;
    m_spanGeometry.terrain_point_count = 0;

    call DynamicLineRating.configure(&m_conductorProps);
    call CatenarySag.configureSpan(&m_spanGeometry);
    call TiltToSag.configureMotePlacement(2.0f, DEFAULT_SPAN_LENGTH_M);
    call CorridorRouting.initRouting(m_nodeId, m_spanId);
    call MacTsch.initTsch(TSCH_SLOTFRAME_LENGTH);

    return SAGITTA_SUCCESS;
  }

  event void DynamicLineRating.ratingUpdated(const msg_dlr_state_t* state) {
    if (state) {
      call CorridorRouting.routeToGateway((const uint8_t*)state, sizeof(msg_dlr_state_t));
    }
  }

  event void DynamicLineRating.thermalAlarm(int16_t currentTempC, int16_t maxAllowedTempC, alarm_level_t severity) {
    /* High priority transmission */
  }

  event void GroundClearance.clearanceBreached(float currentClearanceM, float statutoryMarginM, float criticalLocationX) {
    /* Critical clearance breach alert */
  }

  event void IceAccretion.iceAlarm(float iceThicknessMm, float extraWeightNpm, alarm_level_t severity) {
    /* Ice storm accretion warning */
  }

  event void VibrationAnalysis.analysisComplete(const msg_vibration_alert_t* alert) {
    if (alert && alert->severity > ALARM_LEVEL_NORMAL) {
      call CorridorRouting.routeToGateway((const uint8_t*)alert, sizeof(msg_vibration_alert_t));
    }
  }

  event void Synchrophasor.phasorFrameReady(const msg_synchrophasor_t* pmuFrame) {
    if (pmuFrame) {
      call CorridorRouting.routeToGateway((const uint8_t*)pmuFrame, sizeof(msg_synchrophasor_t));
    }
  }

  event void TravellingWave.wavefrontCaptured(const msg_wavefront_event_t* eventData) {
    if (eventData) {
      call MacTsch.sendPacket((const uint8_t*)eventData, sizeof(msg_wavefront_event_t), TRUE);
    }
  }

  event void EnergyHarvest.powerModeChanged(power_mode_t oldMode, power_mode_t newMode, float supercapVoltageVolts) {
    /* Adjust duty-cycles */
  }

  event void CorridorRouting.telemetryDelivered(const uint8_t* payload, uint8_t length, uint16_t originNodeId) {
  }
}
