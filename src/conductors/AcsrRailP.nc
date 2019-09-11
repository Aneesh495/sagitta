#include "sagitta_types.h"
#include "conductor_params.h"

/**
 * AcsrRailP provides parameters for ACSR 954 kcmil 45/7 "Rail" conductor.
 */
module AcsrRailP {
  provides {
    interface ConductorProfile as Rail;
  }
}
implementation {
  static const conductor_properties_t PROPS = {
    .name = "ACSR_Rail_954",
    .outer_diameter_m = 0.02959f,
    .core_diameter_m = 0.00843f,
    .cross_section_area_m2 = 5.171e-4f,
    .linear_weight_n_per_m = 15.68f,
    .resistance_ref_ohm_per_m = 6.42e-5f,
    .temp_coeff_resistance = 0.0039f,
    .specific_heat_j_kg_k = 950.0f,
    .mass_kg_per_m = 1.599f,
    .emissivity = 0.80f,
    .absorptivity = 0.80f,
    .elastic_modulus_pa = 6.8e10f,
    .thermal_expansion_coeff = 2.05e-5f,
    .rated_tensile_strength_n = 115000.0f,
    .max_allowable_temp_c = 75.0f,
    .emergency_temp_c = 100.0f
  };

  command void Rail.getProperties(conductor_properties_t* propsOut) {
    if (propsOut) memcpy(propsOut, &PROPS, sizeof(conductor_properties_t));
  }

  command float Rail.getResistanceAtTemp(float conductorTempC) {
    return PROPS.resistance_ref_ohm_per_m * (1.0f + PROPS.temp_coeff_resistance * (conductorTempC - 20.0f));
  }

  command float Rail.getThermalStrain(float conductorTempC, float referenceTempC) {
    return PROPS.thermal_expansion_coeff * (conductorTempC - referenceTempC);
  }

  command float Rail.getTensionFromSag(float midspanSagM, float spanLengthM) {
    if (midspanSagM <= 0.01f || spanLengthM <= 1.0f) return 50000.0f;
    return (PROPS.linear_weight_n_per_m * spanLengthM * spanLengthM) / (8.0f * midspanSagM);
  }
}
