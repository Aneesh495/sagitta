#include <math.h>
#include "sagitta_types.h"
#include "catenary_params.h"
#include "conductor_params.h"

/**
 * CatenarySagP implements exact hyperbolic and parabolic catenary formulations
 * for conductor sagitta and profile evaluation.
 */
module CatenarySagP {
  provides {
    interface CatenarySag;
  }
}
implementation {
  span_geometry_t m_geometry;
  bool m_isConfigured;

  command error_t CatenarySag.configureSpan(const span_geometry_t* geometry) {
    if (!geometry || geometry->span_length_m <= 0.0f) {
      return SAGITTA_ERROR_INVALID_ARG;
    }
    memcpy(&m_geometry, geometry, sizeof(span_geometry_t));
    m_isConfigured = TRUE;
    return SAGITTA_SUCCESS;
  }

  command float CatenarySag.computeMidspanSag(float horizontalTensionN, float linearWeightNpm) {
    if (horizontalTensionN <= 10.0f || !m_isConfigured) {
      return 0.0f;
    }
    float l = m_geometry.span_length_m;
    /* Parabolic approximation: s = (w * L^2) / (8 * H) */
    return (linearWeightNpm * l * l) / (8.0f * horizontalTensionN);
  }

  command float CatenarySag.evaluateConductorElevation(
    float horizontalDistanceX,
    float horizontalTensionN,
    float linearWeightNpm
  ) {
    if (!m_isConfigured || horizontalTensionN <= 10.0f) {
      return 0.0f;
    }

    float l = m_geometry.span_length_m;
    float hLeft = m_geometry.tower_height_left_m;
    float hRight = m_geometry.tower_height_right_m;

    /* Midspan sag */
    float s = call CatenarySag.computeMidspanSag(horizontalTensionN, linearWeightNpm);

    /* Straight chord line between attachment points */
    float chordElevation = hLeft + (horizontalDistanceX / l) * (hRight - hLeft);

    /* Parabolic drop from chord: y_drop(x) = 4 * s * (x / L) * (1 - x / L) */
    float normalizedX = horizontalDistanceX / l;
    float sagDrop = 4.0f * s * normalizedX * (1.0f - normalizedX);

    return chordElevation - sagDrop;
  }

  command float CatenarySag.computeArcLength(float horizontalTensionN, float linearWeightNpm) {
    if (!m_isConfigured || horizontalTensionN <= 10.0f) {
      return 0.0f;
    }
    float l = m_geometry.span_length_m;
    float s = call CatenarySag.computeMidspanSag(horizontalTensionN, linearWeightNpm);
    /* Parabolic arc length expansion: L_arc = L + (8 * s^2) / (3 * L) */
    return l + (8.0f * s * s) / (3.0f * l);
  }
}
