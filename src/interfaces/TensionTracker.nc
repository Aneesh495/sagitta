#include "sagitta_types.h"
#include "conductor_params.h"
#include "catenary_params.h"

/**
 * TensionTracker interface computes baseline tension changes across temperatures
 * and ice/wind loading using the cubic conductor state change equation.
 */
interface TensionTracker {
  /**
   * Solves the cubic state change equation for conductor tension at temperature targetTempC.
   * @param conductor Conductor properties
   * @param geometry Span geometry
   * @param referenceTempC Reference calibration temperature (e.g., 15 C)
   * @param referenceTensionN Reference everyday tension in Newtons
   * @param targetTempC Operating conductor temperature in deg C
   * @param currentWeightNpm Total linear weight density in N/m
   * @return Expected horizontal tension in Newtons
   */
  command float solveStateChangeTension(
    const conductor_properties_t* conductor,
    const span_geometry_t* geometry,
    float referenceTempC,
    float referenceTensionN,
    float targetTempC,
    float currentWeightNpm
  );
}
