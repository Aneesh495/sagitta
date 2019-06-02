#include <math.h>
#include "sagitta_types.h"
#include "catenary_params.h"

/**
 * GroundClearanceP compares the dynamic catenary elevation curve against
 * surveyed terrain profile coordinates to enforce statutory clearances.
 */
module GroundClearanceP {
  provides {
    interface GroundClearance;
  }
  uses {
    interface CatenarySag;
  }
}
implementation {
  command error_t GroundClearance.evaluateClearance(
    const span_geometry_t* geometry,
    float midspanSagM,
    float* minClearanceMOut,
    float* criticalLocationXOut
  ) {
    if (!geometry || !minClearanceMOut || !criticalLocationXOut) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    float l = geometry->span_length_m;
    float hLeft = geometry->tower_height_left_m;
    float hRight = geometry->tower_height_right_m;
    float minClearance = 1e6f;
    float criticalX = l * 0.5f;

    uint8_t count = geometry->terrain_point_count;
    if (count == 0) {
      /* Fallback: evaluate clearance at midpoint against zero elevation */
      float midChord = (hLeft + hRight) * 0.5f;
      minClearance = midChord - midspanSagM;
      criticalX = l * 0.5f;
    } else {
      for (uint8_t i = 0; i < count; i++) {
        float x = geometry->terrain_x_m[i];
        float zTerrain = geometry->terrain_elevation_m[i];

        /* Conductor elevation at x */
        float normalizedX = x / l;
        float chordElevation = hLeft + normalizedX * (hRight - hLeft);
        float sagDrop = 4.0f * midspanSagM * normalizedX * (1.0f - normalizedX);
        float conductorElevation = chordElevation - sagDrop;

        float clearanceAtX = conductorElevation - zTerrain;
        if (clearanceAtX < minClearance) {
          minClearance = clearanceAtX;
          criticalX = x;
        }
      }
    }

    *minClearanceMOut = minClearance;
    *criticalLocationXOut = criticalX;

    /* Signal alert if clearance drops below statutory safety limit */
    if (minClearance < geometry->statutory_clearance_m) {
      signal GroundClearance.clearanceBreached(
        minClearance, geometry->statutory_clearance_m, criticalX);
    }

    return SAGITTA_SUCCESS;
  }
}
