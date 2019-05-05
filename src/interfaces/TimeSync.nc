#include "sagitta_types.h"

/**
 * TimeSync interface provides sub-microsecond global network time synchronization
 * via linear Flooding Time Synchronization Protocol (FTSP).
 */
interface TimeSync {
  /**
   * Translates local hardware timer ticks to global corridor epoch time.
   * @param localTicks Microcontroller crystal tick counter
   * @param globalTimestampOut Pointer to store translated global timestamp
   * @return SUCCESS if synchronized, ETIMEOUT if synchronization stale
   */
  async command error_t getGlobalTime(
    uint32_t localTicks,
    sagitta_timestamp_t* globalTimestampOut
  );

  /**
   * Updates linear regression table with an SFD-timestamped sync beacon.
   * @param localArrivalTicks Local hardware ticks latched at SFD pin
   * @param rootTimestamp Global timestamp contained in beacon payload
   * @param rootNodeId Master clock source node ID
   */
  command void processSyncBeacon(
    uint32_t localArrivalTicks,
    const sagitta_timestamp_t* rootTimestamp,
    uint16_t rootNodeId
  );

  /**
   * Queries synchronization health and current linear clock skew.
   * @param skewPpmOut Pointer to store estimated crystal drift in parts-per-million
   * @return True if clock is valid and within 2 microsecond tolerance
   */
  command bool isSynchronized(float* skewPpmOut);
}
