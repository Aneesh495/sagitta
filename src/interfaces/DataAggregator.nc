#include "sagitta_types.h"
#include "sagitta_messages.h"

/**
 * DataAggregator interface performs in-network spatial compression
 * combining adjacent span states into packed composite telemetry frames.
 */
interface DataAggregator {
  /**
   * Integrates an adjacent span telemetry report into the aggregation buffer.
   * @param childReport Inbound telemetry payload from downstream neighbor
   * @param localReport Local mote telemetry payload
   * @param aggregatedFrameOut Pointer to store compressed composite payload
   * @param frameLengthOut Pointer to store resulting byte length
   * @return SUCCESS if aggregated
   */
  command error_t aggregateSpanData(
    const msg_dlr_state_t* childReport,
    const msg_dlr_state_t* localReport,
    uint8_t* aggregatedFrameOut,
    uint8_t* frameLengthOut
  );
}
