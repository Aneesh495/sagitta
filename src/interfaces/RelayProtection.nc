#include "sagitta_types.h"

/**
 * RelayProtection interface defines standard ANSI protection relay behavior:
 * pickup detection, inverse-time integration, tripping commands, and lockout.
 */
interface RelayProtection {
  /**
   * Configures relay pickup current/voltage thresholds and time dial settings.
   * @param pickupThreshold Primary pickup threshold (Amperes, Volts, or Ohms)
   * @param timeDial Multiplier for inverse-time curve calculation
   * @return SUCCESS if valid
   */
  command error_t configureRelay(float pickupThreshold, float timeDial);

  /**
   * Evaluates measured electrical quantities and advances internal trip accumulator.
   * @param measuredQuantity Instantaneous or RMS input (e.g., current, voltage, impedance)
   * @param dtSeconds Elapsed time step in seconds
   * @return True if relay has picked up (threshold exceeded)
   */
  command bool evaluateRelay(float measuredQuantity, float dtSeconds);

  /**
   * Resets trip accumulator and clears tripped state.
   */
  command void resetRelay();

  /**
   * Event signaled when relay trips line circuit breaker.
   * @param ansiCode Standard ANSI function code (e.g., 50, 51, 21, 87)
   * @param tripValue Operating quantity at instant of trip
   * @param operatingTimeMs Operating trip time in milliseconds
   */
  event void relayTripped(uint8_t ansiCode, float tripValue, uint32_t operatingTimeMs);
}
