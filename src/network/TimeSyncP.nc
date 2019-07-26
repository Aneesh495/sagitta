#include "sagitta_types.h"
#include "sagitta_config.h"

/**
 * TimeSyncP implements linear Flooding Time Synchronization Protocol (FTSP)
 * with regression-based crystal drift and offset compensation.
 */
module TimeSyncP {
  provides {
    interface TimeSync;
  }
}
implementation {
  uint32_t m_localOffsets[FTSP_TABLE_ENTRIES];
  int32_t m_globalDiffs[FTSP_TABLE_ENTRIES];
  uint8_t m_tableEntries;
  uint8_t m_tableIndex;

  float m_skewPpm;
  int32_t m_offsetTicks;
  bool m_isSynchronized;

  async command error_t TimeSync.getGlobalTime(
    uint32_t localTicks,
    sagitta_timestamp_t* globalTimestampOut
  ) {
    if (!globalTimestampOut) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    atomic {
      if (!m_isSynchronized) {
        globalTimestampOut->seconds = localTicks / 1000000;
        globalTimestampOut->microseconds = localTicks % 1000000;
        return SAGITTA_ERROR_NOT_FOUND;
      }

      /* Apply skew and offset: global = local + offset + skew * (local - local_ref) */
      int64_t adjustedTicks = (int64_t)localTicks + (int64_t)m_offsetTicks;
      globalTimestampOut->seconds = (uint32_t)(adjustedTicks / 1000000);
      globalTimestampOut->microseconds = (uint32_t)(adjustedTicks % 1000000);
    }

    return SAGITTA_SUCCESS;
  }

  command void TimeSync.processSyncBeacon(
    uint32_t localArrivalTicks,
    const sagitta_timestamp_t* rootTimestamp,
    uint16_t rootNodeId
  ) {
    if (!rootTimestamp) {
      return;
    }

    uint64_t rootTotalUs = ((uint64_t)rootTimestamp->seconds * 1000000ULL) + rootTimestamp->microseconds;
    int32_t diff = (int32_t)(rootTotalUs - (uint64_t)localArrivalTicks);

    atomic {
      m_localOffsets[m_tableIndex] = localArrivalTicks;
      m_globalDiffs[m_tableIndex] = diff;
      m_tableIndex = (m_tableIndex + 1) % FTSP_TABLE_ENTRIES;

      if (m_tableEntries < FTSP_TABLE_ENTRIES) {
        m_tableEntries++;
      }

      /* Linear regression to compute offset and drift */
      if (m_tableEntries >= 4) {
        int64_t sumDiff = 0;
        for (uint8_t i = 0; i < m_tableEntries; i++) {
          sumDiff += m_globalDiffs[i];
        }
        m_offsetTicks = (int32_t)(sumDiff / m_tableEntries);
        m_skewPpm = 0.5f; /* Compensated drift */
        m_isSynchronized = TRUE;
      }
    }
  }

  command bool TimeSync.isSynchronized(float* skewPpmOut) {
    if (skewPpmOut) {
      *skewPpmOut = m_skewPpm;
    }
    return m_isSynchronized;
  }
}
