#ifndef CORRIDOR_MODEL_H
#define CORRIDOR_MODEL_H

#include <stdint.h>
#include <stdbool.h>
#include "../../src/include/sagitta_types.h"
#include "../../src/include/conductor_params.h"
#include "../../src/include/catenary_params.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX_SIM_TOWERS 32
#define MAX_SIM_MOTES  96

typedef struct {
  uint16_t mote_id;
  uint16_t span_index;
  phase_id_t phase;
  float conductor_temp_c;
  float midspan_sag_m;
  float min_ground_clearance_m;
  float mechanical_tension_n;
  float ice_thickness_mm;
  float vibration_peak_freq_hz;
  float vibration_bending_strain_ue;
  float cumulative_fatigue_damage;
  float supercap_voltage_v;
  power_mode_t power_mode;
  uint32_t packets_sent;
  uint32_t packets_relayed;
  bool fault_triggered;
  uint32_t fault_arrival_s;
  uint32_t fault_arrival_ns;
} sim_mote_state_t;

typedef struct {
  uint16_t tower_count;
  uint16_t span_count;
  float span_length_m;
  float total_line_length_m;
  conductor_properties_t conductor;
  span_geometry_t spans[MAX_SIM_TOWERS];
  uint16_t mote_count;
  sim_mote_state_t motes[MAX_SIM_MOTES];
} corridor_model_t;

void corridor_model_init(corridor_model_t* model, uint16_t tower_count, float span_length_m);
void corridor_model_update_span(
  corridor_model_t* model,
  uint16_t mote_idx,
  float ambient_temp_c,
  float wind_speed_mps,
  float wind_yaw_deg,
  float solar_flux_wm2,
  float line_current_a,
  float dt_seconds
);

#ifdef __cplusplus
}
#endif

#endif /* CORRIDOR_MODEL_H */
