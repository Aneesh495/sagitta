#include "sagitta_types.h"
#include "conductor_params.h"

/**
 * ConductorProfile interface defines physical, thermal, mechanical,
 * and electrical parameters for specific transmission line wire types.
 */
interface ConductorProfile {
  /**
   * Retrieves full physical and metallurgical parameter structure.
   * @param propsOut Pointer to destination properties structure
   */
  command void getProperties(conductor_properties_t* propsOut);

  /**
   * Computes temperature-adjusted AC resistance per unit length.
   * @param conductorTempC Conductor temperature in deg C
   * @return Resistance in Ohms per meter
   */
  command float getResistanceAtTemp(float conductorTempC);

  /**
   * Computes thermal elongation strain Delta_L / L for given temperature rise.
   * @param conductorTempC Operating conductor temperature in deg C
   * @param referenceTempC Reference temperature in deg C (default: 20 C)
   * @return Dimensionless thermal strain
   */
  command float getThermalStrain(float conductorTempC, float referenceTempC);

  /**
   * Computes catenary horizontal tension for observed midspan sagitta.
   * @param midspanSagM Observed sagitta in meters
   * @param spanLengthM Span length between support towers in meters
   * @return Horizontal mechanical tension in Newtons
   */
  command float getTensionFromSag(float midspanSagM, float spanLengthM);
}
