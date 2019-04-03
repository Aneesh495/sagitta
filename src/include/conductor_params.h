#ifndef CONDUCTOR_PARAMS_H
#define CONDUCTOR_PARAMS_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Physical properties of transmission conductor cables */
typedef struct {
  const char* name;              /* Conductor code name (e.g., Drake, Cardinal) */
  float outer_diameter_m;        /* Total outside diameter (meters) */
  float core_diameter_m;         /* Steel core diameter (meters) */
  float cross_section_area_m2;   /* Total conducting cross-section area (m^2) */
  float linear_weight_n_per_m;   /* Bare conductor weight per unit length (N/m) */
  float resistance_ref_ohm_per_m;/* DC/AC resistance at 20 deg C (Ohm/m) */
  float temp_coeff_resistance;   /* Temperature coefficient of resistance (1/K) */
  float specific_heat_j_kg_k;    /* Composite specific heat capacity (J/(kg*K)) */
  float mass_kg_per_m;           /* Total mass per meter (kg/m) */
  float emissivity;              /* Surface radiation emissivity coefficient */
  float absorptivity;            /* Surface solar radiation absorptivity */
  float elastic_modulus_pa;      /* Effective elastic modulus (Pascals) */
  float thermal_expansion_coeff; /* Coefficient of linear thermal expansion (1/K) */
  float rated_tensile_strength_n;/* Rated breaking strength (Newtons) */
  float max_allowable_temp_c;    /* Continuous thermal rating limit (deg C) */
  float emergency_temp_c;        /* 15-minute emergency rating limit (deg C) */
} conductor_properties_t;

/* Standard conductor catalog presets */
extern const conductor_properties_t CONDUCTOR_ACSR_DRAKE_795;
extern const conductor_properties_t CONDUCTOR_ACSR_GROSBEAK_636;
extern const conductor_properties_t CONDUCTOR_ACSR_CARDINAL_954;
extern const conductor_properties_t CONDUCTOR_ACSS_CURLEW_1033;

#ifdef __cplusplus
}
#endif

#endif /* CONDUCTOR_PARAMS_H */
