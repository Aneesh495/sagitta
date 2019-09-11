#include "sagitta_types.h"
#include "conductor_params.h"

/**
 * AcsrFinchP provides parameters for ACSR 1113 kcmil 54/19 "Finch" conductor.
 */
module AcsrFinchP {
  provides {
    interface ConductorProfile as Finch;
  }
}
implementation {
  static const conductor_properties_t PROPS = {
    .name = "ACSR_Finch_1113",
    .outer_diameter_m = 0.03284f,
    .core_diameter_m = 0.01095f,
    .cross_section_area_m2 = 6.387e-4f,
    .linear_weight_n_per_m = 20.89f,
    .resistance_ref_ohm_per_m = 5.20e-5f,
    .temp_coeff_resistance = 0.0039f,
    .specific_heat_j_kg_k = 950.0f,
    .mass_kg_per_m = 2.130f,
    .emissivity = 0.80f,
    .absorptivity = 0.80f,
    .elastic_modulus_pa = 7.0e10f,
    .thermal_expansion_coeff = 1.94e-5f,
    .rated_tensile_strength_n = 173000.0f,
    .max_allowable_temp_c = 75.0f,
    .emergency_temp_c = 100.0f
  };

  command void Finch.getProperties(conductor_properties_t* propsOut) {
    if (propsOut) memcpy(propsOut, &PROPS, sizeof(conductor_properties_t));
  }

  command float Finch.getResistanceAtTemp(float conductorTempC) {
    return PROPS.resistance_ref_ohm_per_m * (1.0f + PROPS.temp_coeff_resistance * (conductorTempC - 20.0f));
  }

  command float Finch.getThermalStrain(float conductorTempC, float referenceTempC) {
    return PROPS.thermal_expansion_coeff * (conductorTempC - referenceTempC);
  }

  command float Finch.getTensionFromSag(float midspanSagM, float spanLengthM) {
    if (midspanSagM <= 0.01f || spanLengthM <= 1.0f) return 65000.0f;
    return (PROPS.linear_weight_n_per_m * spanLengthM * spanLengthM) / (8.0f * midspanSagM);
  }
}
