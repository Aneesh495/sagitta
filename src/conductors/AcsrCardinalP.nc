#include "sagitta_types.h"
#include "conductor_params.h"

/**
 * AcsrCardinalP provides parameters for ACSR 954 kcmil 54/7 "Cardinal" conductor.
 */
module AcsrCardinalP {
  provides {
    interface ConductorProfile as Cardinal;
  }
}
implementation {
  static const conductor_properties_t PROPS = {
    .name = "ACSR_Cardinal_954",
    .outer_diameter_m = 0.03038f,
    .core_diameter_m = 0.01013f,
    .cross_section_area_m2 = 5.474e-4f,
    .linear_weight_n_per_m = 17.91f,
    .resistance_ref_ohm_per_m = 6.06e-5f,
    .temp_coeff_resistance = 0.0039f,
    .specific_heat_j_kg_k = 950.0f,
    .mass_kg_per_m = 1.826f,
    .emissivity = 0.80f,
    .absorptivity = 0.80f,
    .elastic_modulus_pa = 7.0e10f,
    .thermal_expansion_coeff = 1.94e-5f,
    .rated_tensile_strength_n = 151000.0f,
    .max_allowable_temp_c = 75.0f,
    .emergency_temp_c = 100.0f
  };

  command void Cardinal.getProperties(conductor_properties_t* propsOut) {
    if (propsOut) memcpy(propsOut, &PROPS, sizeof(conductor_properties_t));
  }

  command float Cardinal.getResistanceAtTemp(float conductorTempC) {
    return PROPS.resistance_ref_ohm_per_m * (1.0f + PROPS.temp_coeff_resistance * (conductorTempC - 20.0f));
  }

  command float Cardinal.getThermalStrain(float conductorTempC, float referenceTempC) {
    return PROPS.thermal_expansion_coeff * (conductorTempC - referenceTempC);
  }

  command float Cardinal.getTensionFromSag(float midspanSagM, float spanLengthM) {
    if (midspanSagM <= 0.01f || spanLengthM <= 1.0f) return 60000.0f;
    return (PROPS.linear_weight_n_per_m * spanLengthM * spanLengthM) / (8.0f * midspanSagM);
  }
}
