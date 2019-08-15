#ifndef SAGITTA_SIM_H
#define SAGITTA_SIM_H

#include <stdint.h>
#include <stdbool.h>
#include "corridor_model.h"
#include "weather_generator.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
  corridor_model_t corridor;
  weather_profile_t weather_profile;
  float sim_time_seconds;
  float time_step_seconds;
  float line_current_rms_a;
  uint32_t total_telemetry_delivered;
  uint32_t total_alarms_detected;
  bool fault_active;
  float fault_location_m;
} sagitta_simulation_t;

void sagitta_sim_init(sagitta_simulation_t* sim, uint16_t tower_count, float span_length_m);
void sagitta_sim_step(sagitta_simulation_t* sim);
void sagitta_sim_inject_fault(sagitta_simulation_t* sim, float distance_from_substation_m);
void sagitta_sim_set_load_current(sagitta_simulation_t* sim, float current_a);

#ifdef __cplusplus
}
#endif

#endif /* SAGITTA_SIM_H */
