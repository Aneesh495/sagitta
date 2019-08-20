#include <stdio.h>
#include <math.h>
#include "../test_runner.h"
#include "../../sim/engine/sagitta_sim.h"
#include "../../sim/scada/dnp3_gateway.h"

bool test_corridor_24h_diurnal_cycle(void) {
  sagitta_simulation_t sim;
  sagitta_sim_init(&sim, 16, 300.0f); /* 16 towers, 15 spans, 4500 m */
  sagitta_sim_set_load_current(&sim, 800.0f);

  /* Run 60 simulation steps (fast-forwarding) */
  for (int i = 0; i < 60; i++) {
    sagitta_sim_step(&sim);
  }

  TEST_ASSERT(sim.total_telemetry_delivered >= 2000);
  TEST_ASSERT(sim.corridor.motes[0].conductor_temp_c > 20.0f);
  TEST_ASSERT(sim.corridor.motes[0].min_ground_clearance_m > 7.5f);
  return true;
}

bool test_fault_injection_and_twfl_capture(void) {
  sagitta_simulation_t sim;
  sagitta_sim_init(&sim, 20, 300.0f); /* 20 towers, 5700 m */
  float faultDistanceM = 1850.0f;

  sagitta_sim_inject_fault(&sim, faultDistanceM);
  TEST_ASSERT(sim.fault_active);
  TEST_ASSERT_EQUAL_INT(sim.corridor.motes[0].fault_triggered, true);

  /* Verify wavefront arrival times increase with distance from fault */
  uint32_t tArrival0 = sim.corridor.motes[0].fault_arrival_ns;
  /* Mote near fault (span 6 is at 1800 m) */
  uint32_t tArrivalNear = sim.corridor.motes[18].fault_arrival_ns;
  TEST_ASSERT(tArrivalNear < tArrival0);
  return true;
}

bool test_dnp3_scada_export_pipeline(void) {
  sagitta_simulation_t sim;
  dnp3_outstation_t scada;

  sagitta_sim_init(&sim, 10, 300.0f);
  dnp3_gateway_init(&scada);

  sagitta_sim_step(&sim);
  dnp3_gateway_update(&scada, &sim);

  TEST_ASSERT(scada.analog_point_count >= 30);
  TEST_ASSERT(scada.binary_point_count >= 15);

  uint8_t buffer[64];
  uint16_t len = dnp3_gateway_export_frame(&scada, buffer, sizeof(buffer));
  TEST_ASSERT_EQUAL_INT(len, 10);
  TEST_ASSERT_EQUAL_INT(buffer[0], 0x05);
  TEST_ASSERT_EQUAL_INT(buffer[1], 0x64);
  return true;
}
