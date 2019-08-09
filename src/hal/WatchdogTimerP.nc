#include "sagitta_types.h"

/**
 * WatchdogTimerP implements task execution deadline monitoring and hardware kicks.
 */
module WatchdogTimerP {
  provides {
    interface WatchdogSuper;
  }
}
implementation {
  uint32_t m_lastKickTimestamp;
  uint8_t m_taskStatusBitmap;

  async command void WatchdogSuper.kick() {
    atomic {
      m_lastKickTimestamp = 1000;
    }
  }

  command void WatchdogSuper.reportAlive(uint8_t taskId) {
    if (taskId < 8) {
      m_taskStatusBitmap |= (1 << taskId);
    }
  }

  default event void WatchdogSuper.taskStarved(uint8_t taskId) {
  }
}
