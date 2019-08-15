#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "sagitta_sim.h"

void sagitta_sim_init(sagitta_simulation_t* sim, uint16_t tower_count, float span_length_m) {
  if (!sim) return;
  memset(sim, 0, sizeof(sagitta_simulation_t));

  corridor_model_init(&sim->corridor, tower_count, span_length_m);
  weather_generator_init_default(&sim->weather_profile);

  sim->sim_time_seconds = 0.0f;
  sim->time_step_seconds = 1.0f; /* 1 second discrete steps */
  sim->line_current_rms_a = 650.0f; /* 650 A initial transmission load */
  sim->total_telemetry_delivered = 0;
  sim->total_alarms_detected = 0;
  sim->fault_active = FALSE;
  sim->fault_location_m = 0.0f;
}

void sagitta_sim_set_load_current(sagitta_simulation_t* sim, float current_a) {
  if (sim) {
    sim->line_current_rms_a = current_a;
  }
}

void sagitta_sim_inject_fault(sagitta_simulation_t* sim, float distance_from_substation_m) {
  if (!sim) return;
  sim->fault_active = TRUE;
  sim->fault_location_m = distance_from_substation_m;

  /* Wavefront propagation at speed of light in air: v = 294,000,000 m/s */
  float v = 2.94e8f;
  uint32_t baseS = (uint32_t)sim->sim_time_seconds;

  for (uint16_t i = 0; i < sim->corridor.mote_count; i++) {
    sim_mote_state_t* m = &sim->corridor.motes[i];
    float moteDistM = (float)m->span_index * sim->corridor.span_length_m;
    float distToFault = fabsf(moteDistM - distance_from_substation_m);
    float arrivalSec = distToFault / v;

    m->fault_triggered = TRUE;
    m->fault_arrival_s = baseS;
    m->fault_arrival_ns = (uint32_t)(arrivalSec * 1e9f);
  }
  sim->total_alarms_detected++;
}

void sagitta_sim_step(sagitta_simulation_t* sim) {
  if (!sim) return;

  weather_snapshot_t w = weather_generator_sample(&sim->weather_profile, sim->sim_time_seconds);

  for (uint16_t i = 0; i < sim->corridor.mote_count; i++) {
    corridor_model_update_span(
      &sim->corridor,
      i,
      w.ambient_temp_c,
      w.wind_speed_mps,
      w.wind_yaw_deg,
      w.solar_flux_wm2,
      sim->line_current_rms_a,
      sim->time_step_seconds
    );

    /* Telemetry propagation to gateway: hop-by-hop */
    sim_mote_state_t* m = &sim->corridor.motes[i];
    if (m->conductor_temp_c > 75.0f || m->min_ground_clearance_m < 7.5f) {
      sim->total_alarms_detected++;
    }
    sim->total_telemetry_delivered++;
  }

  sim->sim_time_seconds += sim->time_step_seconds;
}
