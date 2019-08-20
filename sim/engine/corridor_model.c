#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "corridor_model.h"

void corridor_model_init(corridor_model_t* model, uint16_t tower_count, float span_length_m) {
  if (!model) return;
  memset(model, 0, sizeof(corridor_model_t));

  model->tower_count = (tower_count <= MAX_SIM_TOWERS) ? tower_count : MAX_SIM_TOWERS;
  model->span_count = model->tower_count - 1;
  model->span_length_m = (span_length_m > 0.0f) ? span_length_m : 300.0f;
  model->total_line_length_m = (float)model->span_count * model->span_length_m;

  /* Standard ACSR Drake 795 kcmil conductor */
  model->conductor.name = "ACSR_Drake_795";
  model->conductor.outer_diameter_m = 0.02814f;
  model->conductor.linear_weight_n_per_m = 15.96f;
  model->conductor.resistance_ref_ohm_per_m = 7.28e-5f;
  model->conductor.temp_coeff_resistance = 0.0039f;
  model->conductor.mass_kg_per_m = 1.628f;
  model->conductor.specific_heat_j_kg_k = 950.0f;
  model->conductor.emissivity = 0.8f;
  model->conductor.absorptivity = 0.8f;
  model->conductor.elastic_modulus_pa = 7.7e10f;
  model->conductor.thermal_expansion_coeff = 1.89e-5f;
  model->conductor.max_allowable_temp_c = 75.0f;
  model->conductor.emergency_temp_c = 100.0f;

  /* Initialize spans and motes: 3 phases per span */
  uint16_t moteIdx = 0;
  for (uint16_t s = 0; s < model->span_count; s++) {
    model->spans[s].span_id = s + 1;
    model->spans[s].span_length_m = model->span_length_m;
    model->spans[s].tower_height_left_m = 35.0f;
    model->spans[s].tower_height_right_m = 35.0f;
    model->spans[s].mote_offset_from_tower_m = 2.0f;
    model->spans[s].design_horizontal_tension_n = 25000.0f;
    model->spans[s].statutory_clearance_m = 7.5f;

    for (int p = 0; p < 3 && moteIdx < MAX_SIM_MOTES; p++) {
      sim_mote_state_t* m = &model->motes[moteIdx];
      m->mote_id = 100 + moteIdx;
      m->span_index = s;
      m->phase = (phase_id_t)p;
      m->conductor_temp_c = 25.0f;
      m->midspan_sag_m = 7.18f;
      m->min_ground_clearance_m = 27.82f;
      m->mechanical_tension_n = 25000.0f;
      m->ice_thickness_mm = 0.0f;
      m->vibration_peak_freq_hz = 12.5f;
      m->vibration_bending_strain_ue = 45.0f;
      m->cumulative_fatigue_damage = 0.0001f;
      m->supercap_voltage_v = 4.2f;
      m->power_mode = POWER_MODE_CONTINUOUS;
      moteIdx++;
    }
  }
  model->mote_count = moteIdx;
}

void corridor_model_update_span(
  corridor_model_t* model,
  uint16_t mote_idx,
  float ambient_temp_c,
  float wind_speed_mps,
  float wind_yaw_deg,
  float solar_flux_wm2,
  float line_current_a,
  float dt_seconds
) {
  if (!model || mote_idx >= model->mote_count) return;

  sim_mote_state_t* m = &model->motes[mote_idx];
  conductor_properties_t* c = &model->conductor;

  /* 1. IEEE 738 Conductor thermal evolution */
  float d = c->outer_diameter_m;
  float filmTempC = (m->conductor_temp_c + ambient_temp_c) * 0.5f;
  float deltaT = m->conductor_temp_c - ambient_temp_c;
  if (deltaT < 0.0f) deltaT = 0.0f;

  /* Forced convective cooling */
  float kf = 2.424e-2f + 7.477e-5f * filmTempC;
  float rho = 1.293f * (273.15f / (filmTempC + 273.15f));
  float mu = 1.8e-5f;
  float re = (d * rho * wind_speed_mps) / mu;
  float rad = fabsf(wind_yaw_deg) * (3.14159265f / 180.0f);
  float kAngle = 1.194f - cosf(rad) + 0.194f * cosf(2.0f * rad) + 0.368f * sinf(2.0f * rad);
  if (kAngle < 0.2f) kAngle = 0.2f;

  float qc1 = (1.01f + 1.35f * powf(re, 0.52f)) * kf * deltaT * kAngle;
  float qc2 = (0.754f * powf(re, 0.6f)) * kf * deltaT * kAngle;
  float qc = (qc1 > qc2) ? qc1 : qc2;
  float qcn = 3.645f * powf(rho, 0.5f) * powf(d, 0.75f) * powf(deltaT, 1.25f);
  if (qcn > qc) qc = qcn;

  /* Radiative cooling */
  float tcRatio = (m->conductor_temp_c + 273.15f) / 100.0f;
  float taRatio = (ambient_temp_c + 273.15f) / 100.0f;
  float qr = 17.8f * d * c->emissivity * (powf(tcRatio, 4.0f) - powf(taRatio, 4.0f));
  if (qr < 0.0f) qr = 0.0f;

  /* Solar gain */
  float qs = c->absorptivity * solar_flux_wm2 * d;

  /* Joule heating */
  float rAdj = c->resistance_ref_ohm_per_m * (1.0f + c->temp_coeff_resistance * (m->conductor_temp_c - 20.0f));
  float qj = line_current_a * line_current_a * rAdj;

  /* Differential step */
  float heatCapacity = c->mass_kg_per_m * c->specific_heat_j_kg_k;
  float dTemp = ((qj + qs - qc - qr) / heatCapacity) * dt_seconds;
  m->conductor_temp_c += dTemp;

  /* 2. Catenary mechanics update */
  /* Thermal expansion elongation changes tension and sag */
  float refTension = model->spans[m->span_index].design_horizontal_tension_n;
  float tempDiff = m->conductor_temp_c - 15.0f; /* 15 C reference */
  float tensionDrop = tempDiff * 80.0f; /* ~80 N drop per deg C rise */
  m->mechanical_tension_n = refTension - tensionDrop;
  if (m->mechanical_tension_n < 5000.0f) m->mechanical_tension_n = 5000.0f;

  /* Linear weight with ice */
  float totalWeight = c->linear_weight_n_per_m;
  if (m->ice_thickness_mm > 0.0f) {
    float rIceM = m->ice_thickness_mm * 1e-3f;
    float iceArea = 3.14159265f * (d * rIceM + rIceM * rIceM);
    totalWeight += iceArea * 900.0f * 9.80665f;
  }

  /* Midspan sag: s = w * L^2 / (8 * H) */
  float l = model->span_length_m;
  m->midspan_sag_m = (totalWeight * l * l) / (8.0f * m->mechanical_tension_n);

  /* Ground clearance: Tower attachment (35 m) minus midspan sag */
  m->min_ground_clearance_m = 35.0f - m->midspan_sag_m;

  /* 3. Aeolian vibration */
  /* Karman vortex shedding: f_s = St * V / D */
  if (wind_speed_mps > 0.5f) {
    m->vibration_peak_freq_hz = (0.19f * wind_speed_mps) / d;
    m->vibration_bending_strain_ue = 30.0f + wind_speed_mps * 15.0f;
  } else {
    m->vibration_peak_freq_hz = 0.0f;
    m->vibration_bending_strain_ue = 5.0f;
  }

  /* 4. Power harvesting & supercapacitor */
  float turns = 500.0f;
  float iSec = (line_current_a > 1000.0f ? 1000.0f : line_current_a) / turns;
  float pHarvestMw = iSec * iSec * 50.0f * 1000.0f;
  float pDrawMw = 15.0f; /* 15 mW average mote draw */

  float netPowerMw = pHarvestMw - pDrawMw;
  float capC = 50.0f; /* 50 Farads */
  float dEnergyJoules = (netPowerMw * 0.001f) * dt_seconds;
  float currentEnergy = 0.5f * capC * m->supercap_voltage_v * m->supercap_voltage_v;
  currentEnergy += dEnergyJoules;
  if (currentEnergy < 1.0f) currentEnergy = 1.0f;
  m->supercap_voltage_v = sqrtf((2.0f * currentEnergy) / capC);
  if (m->supercap_voltage_v > 5.0f) m->supercap_voltage_v = 5.0f;

  if (m->supercap_voltage_v < 2.5f) {
    m->power_mode = POWER_MODE_HIBERNATE;
  } else if (m->supercap_voltage_v < 3.2f) {
    m->power_mode = POWER_MODE_ECO;
  } else if (line_current_a > 250.0f) {
    m->power_mode = POWER_MODE_BURST;
  } else {
    m->power_mode = POWER_MODE_CONTINUOUS;
  }

  m->packets_sent++;
}
