#ifndef CATENARY_PARAMS_H
#define CATENARY_PARAMS_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

#define MAX_TERRAIN_PROFILE_POINTS 16

/* Span physical installation geometry */
typedef struct {
  uint16_t span_id;
  float    span_length_m;          /* Horizontal distance between towers (m) */
  float    tower_height_left_m;    /* Support attachment elevation A (m) */
  float    tower_height_right_m;   /* Support attachment elevation B (m) */
  float    mote_offset_from_tower_m;/* Mounting position relative to tower clamp (m) */
  float    design_horizontal_tension_n;/* Everyday design tension at 15 C (N) */
  float    statutory_clearance_m;  /* Minimum legal ground clearance (m) */
  uint8_t  terrain_point_count;
  float    terrain_x_m[MAX_TERRAIN_PROFILE_POINTS];
  float    terrain_elevation_m[MAX_TERRAIN_PROFILE_POINTS];
} span_geometry_t;

/* Atmospheric ice parameters */
typedef struct {
  float ice_density_kg_per_m3;    /* Standard glaze ice density (~900 kg/m^3) */
  float drag_increase_factor;     /* Aerodynamic drag multiplier under icing */
  float critical_weight_thresh_n; /* Alert threshold for ice load (N/m) */
} ice_parameters_t;

#ifdef __cplusplus
}
#endif

#endif /* CATENARY_PARAMS_H */
