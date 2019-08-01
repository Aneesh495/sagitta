#include "sagitta_types.h"
#include "sagitta_messages.h"

/**
 * DataAggregatorP combines neighboring span telemetry frames into
 * packed composite records to minimize wireless airtime.
 */
module DataAggregatorP {
  provides {
    interface DataAggregator;
  }
}
implementation {
  command error_t DataAggregator.aggregateSpanData(
    const msg_dlr_state_t* childReport,
    const msg_dlr_state_t* localReport,
    uint8_t* aggregatedFrameOut,
    uint8_t* frameLengthOut
  ) {
    if (!childReport || !localReport || !aggregatedFrameOut || !frameLengthOut) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    /* Serialize composite header + both state reports */
    uint8_t offset = 0;
    memcpy(aggregatedFrameOut + offset, localReport, sizeof(msg_dlr_state_t));
    offset += sizeof(msg_dlr_state_t);

    memcpy(aggregatedFrameOut + offset, childReport, sizeof(msg_dlr_state_t));
    offset += sizeof(msg_dlr_state_t);

    *frameLengthOut = offset;
    return SAGITTA_SUCCESS;
  }
}
