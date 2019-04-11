#ifndef VIBRATION_PARAMS_H
#define VIBRATION_PARAMS_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Vibration analysis settings and fatigue coefficients */
typedef struct {
  float strouhal_number;         /* Typically 0.185 to 0.20 for stranded cables */
  float clamp_distance_xb_m;     /* Standard distance from clamp (0.089 m = 3.5 in) */
  float flexural_rigidity_ei;    /* Conductor bending stiffness EI (N * m^2) */
  float sn_curve_constant_c;     /* EPRI safe-border endurance constant */
  float sn_curve_exponent_m;     /* Fatigue curve slope exponent (~4.5) */
  float fatigue_limit_microstrain;/* Endurance limit (typically 150 to 200 microstrain) */
  float galloping_freq_low_hz;   /* Galloping lower band (e.g., 0.1 Hz) */
  float galloping_freq_high_hz;  /* Galloping upper band (e.g., 2.0 Hz) */
  float galloping_min_amp_m;     /* Galloping amplitude threshold (e.g., 0.2 m) */
} vibration_parameters_t;

#ifdef __cplusplus
}
#endif

#endif /* VIBRATION_PARAMS_H */
