#include "sagitta_types.h"
#include "catenary_params.h"
#include "conductor_params.h"

/**
 * CatenarySag interface provides mathematical evaluation of exact hyperbolic
 * and parabolic catenary profiles, mid-span sagitta, and curve elevation.
 */
interface CatenarySag {
  /**
   * Initializes span geometry and installation constraints.
   * @param geometry Span physical dimensions and elevations
   * @return SUCCESS if valid, EINVAL if parameters invalid
   */
  command error_t configureSpan(const span_geometry_t* geometry);

  /**
   * Computes the maximum mid-span sagitta distance for given horizontal tension.
   * @param horizontalTensionN Horizontal mechanical tension in Newtons
   * @param linearWeightNpm Total linear weight density in N/m
   * @return Mid-span sagitta in meters
   */
  command float computeMidspanSag(float horizontalTensionN, float linearWeightNpm);

  /**
   * Evaluates conductor vertical elevation y(x) at distance x from left support.
   * @param horizontalDistanceX Distance from left tower (0 <= x <= span_length)
   * @param horizontalTensionN Horizontal tension in Newtons
   * @param linearWeightNpm Total linear weight in N/m
   * @return Elevation in meters relative to reference datum
   */
  command float evaluateConductorElevation(
    float horizontalDistanceX,
    float horizontalTensionN,
    float linearWeightNpm
  );

  /**
   * Computes conductor arc length along the catenary curve.
   * @param horizontalTensionN Horizontal tension in Newtons
   * @param linearWeightNpm Total linear weight in N/m
   * @return Total curved conductor length in meters
   */
  command float computeArcLength(float horizontalTensionN, float linearWeightNpm);
}
