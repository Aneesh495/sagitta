#ifndef WAVEFRONT_PARAMS_H
#define WAVEFRONT_PARAMS_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Travelling wave transient capture parameters */
typedef struct {
  float wave_propagation_velocity_m_us;/* Aerial line velocity (~294.0 m/microsecond) */
  float trigger_threshold_mv;          /* High-speed comparator trip threshold */
  float min_pulse_width_ns;            /* Minimum pulse duration to reject noise */
  float surge_impedance_ohms;          /* Characteristic surge impedance Z0 (~350 Ohms) */
  uint16_t pre_trigger_samples;        /* Ring buffer samples retained before trigger */
  uint16_t post_trigger_samples;       /* Ring buffer samples captured after trigger */
} wavefront_config_t;

#ifdef __cplusplus
}
#endif

#endif /* WAVEFRONT_PARAMS_H */
