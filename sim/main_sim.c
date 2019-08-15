#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "engine/sagitta_sim.h"
#include "scada/dnp3_gateway.h"

static void print_banner(void) {
  printf("===============================================================================\n");
  printf("  SAGITTA :: Autonomous High-Voltage Dynamic Line Rating & Corridor Simulator  \n");
  printf("  Embedded nesC Cyber-Physical Engine for Overhead Transmission Intelligence   \n");
  printf("===============================================================================\n\n");
}

static void print_dashboard(const sagitta_simulation_t* sim, const dnp3_outstation_t* scada) {
  weather_snapshot_t w = weather_generator_sample(&sim->weather_profile, sim->sim_time_seconds);

  printf("\033[H\033[J"); /* Clear screen */
  print_banner();

  printf("Time: %8.1f s | Load: %6.1f A | Ambient: %5.1f C | Wind: %4.1f m/s @ %4.0f deg | Solar: %5.0f W/m^2\n",
         sim->sim_time_seconds, sim->line_current_rms_a, w.ambient_temp_c, w.wind_speed_mps,
         w.wind_yaw_deg, w.solar_flux_wm2);
  printf("Corridor: %d Towers (%d Spans, %5.0f m total) | Motes Active: %d | DNP3 Points: %d\n",
         sim->corridor.tower_count, sim->corridor.span_count, sim->corridor.total_line_length_m,
         sim->corridor.mote_count, scada->analog_point_count);
  printf("Telemetry Frames Relayed: %u | Grid Alarms Detected: %u\n",
         sim->total_telemetry_delivered, sim->total_alarms_detected);
  printf("-------------------------------------------------------------------------------\n");
  printf(" Span | Phase | Temp (C) | Sagitta (m) | Clearance (m) | Tension (N) | Power Mode \n");
  printf("------+-------+----------+-------------+---------------+-------------+------------\n");

  /* Print sample spans */
  for (uint16_t i = 0; i < sim->corridor.mote_count && i < 18; i++) {
    const sim_mote_state_t* m = &sim->corridor.motes[i];
    const char* phaseStr = (m->phase == PHASE_A) ? "  A  " : (m->phase == PHASE_B) ? "  B  " : "  C  ";
    const char* pwrStr = (m->power_mode == POWER_MODE_BURST) ? "BURST" :
                         (m->power_mode == POWER_MODE_CONTINUOUS) ? "CONTINUOUS" :
                         (m->power_mode == POWER_MODE_ECO) ? "ECO" : "HIBERNATE";

    char alertMark = ' ';
    if (m->conductor_temp_c >= 75.0f || m->min_ground_clearance_m < 7.5f) {
      alertMark = '!';
    }

    printf("  %2d  | %s |  %6.1f  |    %6.2f   |    %6.2f %c  |   %7.0f   | %s\n",
           m->span_index + 1, phaseStr, m->conductor_temp_c, m->midspan_sag_m,
           m->min_ground_clearance_m, alertMark, m->mechanical_tension_n, pwrStr);
  }

  if (sim->fault_active) {
    printf("-------------------------------------------------------------------------------\n");
    printf(" [!] TRAVELLING WAVE FAULT DETECTED: Origin at %7.1f m from Substation Busbar\n",
           sim->fault_location_m);
  }
  printf("===============================================================================\n");
}

int main(int argc, char* argv[]) {
  uint32_t maxSteps = 10;
  float loadCurrent = 750.0f;
  float faultDist = -1.0f;
  bool quiet = false;

  for (int i = 1; i < argc; i++) {
    if (strcmp(argv[i], "--steps") == 0 && i + 1 < argc) {
      maxSteps = (uint32_t)atoi(argv[++i]);
    } else if (strcmp(argv[i], "--current") == 0 && i + 1 < argc) {
      loadCurrent = (float)atof(argv[++i]);
    } else if (strcmp(argv[i], "--fault") == 0 && i + 1 < argc) {
      faultDist = (float)atof(argv[++i]);
    } else if (strcmp(argv[i], "--quiet") == 0) {
      quiet = true;
    } else if (strcmp(argv[i], "--help") == 0) {
      print_banner();
      printf("Usage: %s [options]\n", argv[0]);
      printf("  --steps N       Run simulation for N discrete seconds (default: 10)\n");
      printf("  --current A     Set transmission phase current in Amperes (default: 750)\n");
      printf("  --fault DIST    Inject travelling wave fault at DIST meters from gateway\n");
      printf("  --quiet         Run without live ANSI dashboard updates\n");
      printf("  --help          Display this help message\n");
      return 0;
    }
  }

  sagitta_simulation_t sim;
  dnp3_outstation_t scada;

  sagitta_sim_init(&sim, 12, 300.0f); /* 12 towers, 11 spans, 3300 m corridor */
  sagitta_sim_set_load_current(&sim, loadCurrent);
  dnp3_gateway_init(&scada);

  if (faultDist >= 0.0f) {
    sagitta_sim_inject_fault(&sim, faultDist);
  }

  for (uint32_t s = 0; s < maxSteps; s++) {
    sagitta_sim_step(&sim);
    dnp3_gateway_update(&scada, &sim);
    if (!quiet) {
      print_dashboard(&sim, &scada);
    }
  }

  if (quiet) {
    print_banner();
    printf("Simulation completed successfully across %u steps.\n", maxSteps);
    printf("Total telemetry frames: %u | Alarms detected: %u\n",
           sim.total_telemetry_delivered, sim.total_alarms_detected);
  }

  return 0;
}
