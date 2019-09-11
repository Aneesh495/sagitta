#include "sagitta_types.h"
#include "conductor_params.h"

/**
 * AcssCurlewP provides parameters for high-temperature low-sag (HTLS)
 * ACSS 1033.5 kcmil 54/7 "Curlew" conductor (annealed aluminum, 200 C rating).
 */
module AcssCurlewP {
  provides {
    interface ConductorProfile as Curlew;
  }
}
implementation {
  static const conductor_properties_t PROPS = {
    .name = "ACSS_Curlew_1033",
    .outer_diameter_m = 0.03162f,
    .core_diameter_m = 0.01054f,
    .cross_section_area_m2 = 5.928e-4f,
    .linear_weight_n_per_m = 19.32f,
    .resistance_ref_ohm_per_m = 5.59e-5f,
    .temp_coeff_resistance = 0.0040f,
    .specific_heat_j_kg_k = 940.0f,
    .mass_kg_per_m = 1.970f,
    .emissivity = 0.85f,
    .absorptivity = 0.85f,
    .elastic_modulus_pa = 8.3e10f,
    .thermal_expansion_coeff = 1.61e-5f,
    .rated_tensile_strength_n = 120000.0f,
    .max_allowable_temp_c = 200.0f, /* 200 C HTLS continuous rating */
    .emergency_temp_c = 225.0f
  };

  command void Curlew.getProperties(conductor_properties_t* propsOut) {
    if (propsOut) memcpy(propsOut, &PROPS, sizeof(conductor_properties_t));
  }

  command float Curlew.getResistanceAtTemp(float conductorTempC) {
    return PROPS.resistance_ref_ohm_per_m * (1.0f + PROPS.temp_coeff_resistance * (conductorTempC - 20.0f));
  }

  command float Curlew.getThermalStrain(float conductorTempC, float referenceTempC) {
    return PROPS.thermal_expansion_coeff * (conductorTempC - referenceTempC);
  }

  command float Curlew.getTensionFromSag(float midspanSagM, float spanLengthM) {
    if (midspanSagM <= 0.01f || spanLengthM <= 1.0f) return 55000.0f;
    return (PROPS.linear_weight_n_per_m * spanLengthM * spanLengthM) / (8.0f * midspanSagM);
  }
}
