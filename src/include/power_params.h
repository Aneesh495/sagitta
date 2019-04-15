#ifndef POWER_PARAMS_H
#define POWER_PARAMS_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Energy harvesting and storage bank configuration */
typedef struct {
  float ct_turns_ratio;          /* Current transformer primary:secondary turns */
  float ct_burden_resistor_ohms; /* Burden resistance for rectifier */
  float min_harvest_current_a;   /* Minimum line current for harvesting (e.g., 20 A) */
  float saturation_current_a;    /* Magnetic core saturation current clamp (e.g., 1200 A) */
  float supercap_capacitance_f;  /* Total storage capacitance (e.g., 50.0 Farads) */
  float supercap_esr_ohms;       /* Equivalent series resistance */
  float v_shutdown_volts;        /* Minimum operating voltage threshold (e.g., 2.2 V) */
  float v_eco_volts;             /* Eco mode voltage threshold (e.g., 2.7 V) */
  float v_nominal_volts;         /* Standard mode voltage threshold (e.g., 3.6 V) */
  float v_max_clamp_volts;       /* Overvoltage shunt clamp voltage (e.g., 5.0 V) */
  float solar_peak_power_mw;     /* Auxiliary micro-solar peak power (mW) */
} power_system_config_t;

#ifdef __cplusplus
}
#endif

#endif /* POWER_PARAMS_H */
