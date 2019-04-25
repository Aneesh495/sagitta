#include "sagitta_types.h"
#include "catenary_params.h"

/**
 * GroundClearance interface compares dynamic conductor profile against
 * digital terrain profile to monitor statutory clearance compliance.
 */
interface GroundClearance {
  /**
   * Evaluates minimum vertical distance between conductor and underlying terrain.
   * @param geometry Span geometry including terrain profile elevation points
   * @param midspanSagM Current mid-span sagitta in meters
   * @param minClearanceMOut Pointer to store minimum clearance distance in meters
   * @param criticalLocationXOut Pointer to store coordinate of closest point
   * @return SUCCESS if evaluated, EINVAL if geometry null
   */
  command error_t evaluateClearance(
    const span_geometry_t* geometry,
    float midspanSagM,
    float* minClearanceMOut,
    float* criticalLocationXOut
  );

  /**
   * Event signaled when ground clearance breaches statutory safety margin.
   * @param currentClearanceM Instantaneous clearance in meters
   * @param statutoryMarginM Required safety distance in meters
   * @param criticalLocationX Distance from left tower where breach occurs (m)
   */
  event void clearanceBreached(
    float currentClearanceM,
    float statutoryMarginM,
    float criticalLocationX
  );
}
