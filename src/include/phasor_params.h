#ifndef PHASOR_PARAMS_H
#define PHASOR_PARAMS_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Synchrophasor measurement unit configuration */
typedef struct {
  float nominal_frequency_hz;    /* 50.0 Hz or 60.0 Hz */
  float voltage_ratio_divider;   /* Capacitive/resistive divider ratio */
  float current_ratio_ct;        /* Current transformer primary/secondary ratio */
  uint8_t reports_per_second;    /* IEEE C37.118 reporting rate (e.g., 30 or 60) */
  float rocor_filter_cutoff_hz;  /* Low-pass filter cutoff for ROCOF */
  float total_vector_error_limit;/* Statutory maximum TVE (e.g., 1.0 percent) */
} synchrophasor_config_t;

#ifdef __cplusplus
}
#endif

#endif /* PHASOR_PARAMS_H */
