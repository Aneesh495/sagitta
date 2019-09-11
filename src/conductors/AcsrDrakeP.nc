#include "sagitta_types.h"
#include "conductor_params.h"

/**
 * AcsrDrakeP provides metallurgical and physical parameters for
 * ACSR 795 kcmil 26/7 "Drake" conductor.
 */
module AcsrDrakeP {
  provides {
    interface ConductorProfile as Drake;
  }
}
implementation {
  static const conductor_properties_t PROPS = {
    .name = "ACSR_Drake_795",
    .outer_diameter_m = 0.02814f,
    .core_diameter_m = 0.01044f,
    .cross_section_area_m2 = 4.685e-4f,
    .linear_weight_n_per_m = 15.96f,
    .resistance_ref_ohm_per_m = 7.28e-5f,
    .temp_coeff_resistance = 0.0039f,
    .specific_heat_j_kg_k = 950.0f,
    .mass_kg_per_m = 1.628f,
    .emissivity = 0.80f,
    .absorptivity = 0.80f,
    .elastic_modulus_pa = 7.7e10f,
    .thermal_expansion_coeff = 1.89e-5f,
    .rated_tensile_strength_n = 140000.0f,
    .max_allowable_temp_c = 75.0f,
    .emergency_temp_c = 100.0f
  };

  command void Drake.getProperties(conductor_properties_t* propsOut) {
    if (propsOut) memcpy(propsOut, &PROPS, sizeof(conductor_properties_t));
  }

  command float Drake.getResistanceAtTemp(float conductorTempC) {
    return PROPS.resistance_ref_ohm_per_m * (1.0f + PROPS.temp_coeff_resistance * (conductorTempC - 20.0f));
  }

  command float Drake.getThermalStrain(float conductorTempC, float referenceTempC) {
    return PROPS.thermal_expansion_coeff * (conductorTempC - referenceTempC);
  }

  command float Drake.getTensionFromSag(float midspanSagM, float spanLengthM) {
    if (midspanSagM <= 0.01f || spanLengthM <= 1.0f) return 50000.0f;
    return (PROPS.linear_weight_n_per_m * spanLengthM * spanLengthM) / (8.0f * midspanSagM);
  }
}
