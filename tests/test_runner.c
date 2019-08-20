#include <stdio.h>
#include <stdbool.h>
#include "test_runner.h"

int g_tests_run = 0;
int g_tests_passed = 0;
int g_tests_failed = 0;

/* External unit test prototypes */
extern bool test_convective_cooling_forced(void);
extern bool test_convective_cooling_natural(void);
extern bool test_radiative_cooling_stefan_boltzmann(void);
extern bool test_joule_heating_temperature_adjusted(void);
extern bool test_dynamic_ampacity_convergence(void);

extern bool test_catenary_parabolic_sag(void);
extern bool test_tilt_to_sag_conversion(void);
extern bool test_ice_load_radial_thickness(void);
extern bool test_ground_clearance_terrain_profile(void);

extern bool test_fft_spectral_peak_identification(void);
extern bool test_karman_vortex_shedding_frequency(void);
extern bool test_poffenberger_swart_bending_strain(void);
extern bool test_palmgren_miner_fatigue_accumulation(void);

extern bool test_twfl_midpoint_fault(void);
extern bool test_twfl_asymmetric_fault(void);
extern bool test_twfl_sub_microsecond_precision_sensitivity(void);

extern bool test_aes_ccm_roundtrip(void);
extern bool test_induction_harvest_saturation_clamp(void);
extern bool test_supercap_state_of_charge(void);

extern bool test_corridor_24h_diurnal_cycle(void);
extern bool test_fault_injection_and_twfl_capture(void);
extern bool test_dnp3_scada_export_pipeline(void);

void run_test(const char* name, test_func_t func) {
  printf("  [RUN] %-55s ", name);
  fflush(stdout);
  int before_fails = g_tests_failed;
  bool ok = func();
  if (ok && g_tests_failed == before_fails) {
    printf("[PASS]\n");
  } else {
    printf("[FAIL]\n");
  }
}

int main(void) {
  printf("===============================================================================\n");
  printf("  SAGITTA TEST SUITE :: High-Voltage Dynamic Line Rating & Telemetry Engine   \n");
  printf("===============================================================================\n\n");

  printf("== Section 1: IEEE 738 Conductor Heat Balance & Ampacity ==\n");
  run_test("test_convective_cooling_forced", test_convective_cooling_forced);
  run_test("test_convective_cooling_natural", test_convective_cooling_natural);
  run_test("test_radiative_cooling_stefan_boltzmann", test_radiative_cooling_stefan_boltzmann);
  run_test("test_joule_heating_temperature_adjusted", test_joule_heating_temperature_adjusted);
  run_test("test_dynamic_ampacity_convergence", test_dynamic_ampacity_convergence);

  printf("\n== Section 2: Catenary Mechanics, Tilt Filtering, & Ice Accretion ==\n");
  run_test("test_catenary_parabolic_sag", test_catenary_parabolic_sag);
  run_test("test_tilt_to_sag_conversion", test_tilt_to_sag_conversion);
  run_test("test_ice_load_radial_thickness", test_ice_load_radial_thickness);
  run_test("test_ground_clearance_terrain_profile", test_ground_clearance_terrain_profile);

  printf("\n== Section 3: Aeolian Vibration, Fixed-Point FFT, & Fatigue ==\n");
  run_test("test_fft_spectral_peak_identification", test_fft_spectral_peak_identification);
  run_test("test_karman_vortex_shedding_frequency", test_karman_vortex_shedding_frequency);
  run_test("test_poffenberger_swart_bending_strain", test_poffenberger_swart_bending_strain);
  run_test("test_palmgren_miner_fatigue_accumulation", test_palmgren_miner_fatigue_accumulation);

  printf("\n== Section 4: Travelling Wave Fault Location & Sub-Microsecond TWFL ==\n");
  run_test("test_twfl_midpoint_fault", test_twfl_midpoint_fault);
  run_test("test_twfl_asymmetric_fault", test_twfl_asymmetric_fault);
  run_test("test_twfl_sub_microsecond_precision_sensitivity", test_twfl_sub_microsecond_precision_sensitivity);

  printf("\n== Section 5: Security & Energy Harvesting Subsystems ==\n");
  run_test("test_aes_ccm_roundtrip", test_aes_ccm_roundtrip);
  run_test("test_induction_harvest_saturation_clamp", test_induction_harvest_saturation_clamp);
  run_test("test_supercap_state_of_charge", test_supercap_state_of_charge);

  printf("\n== Section 6: End-to-End Corridor & SCADA Pipeline Integration ==\n");
  run_test("test_corridor_24h_diurnal_cycle", test_corridor_24h_diurnal_cycle);
  run_test("test_fault_injection_and_twfl_capture", test_fault_injection_and_twfl_capture);
  run_test("test_dnp3_scada_export_pipeline", test_dnp3_scada_export_pipeline);

  printf("\n===============================================================================\n");
  printf("  Test Summary: %d Assertions Checked | %d Passed | %d Failed\n",
         g_tests_run, g_tests_passed, g_tests_failed);
  printf("===============================================================================\n");

  return (g_tests_failed == 0) ? 0 : 1;
}
