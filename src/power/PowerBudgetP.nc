#include "sagitta_types.h"

/**
 * PowerBudgetP adjusts duty-cycling intervals and RF transmit power
 * according to current system energy harvesting status.
 */
module PowerBudgetP {
  provides {
    interface PowerBudget;
  }
}
implementation {
  command void PowerBudget.calculateTaskSchedule(
    power_mode_t currentMode,
    uint32_t* dlrIntervalMsOut,
    uint32_t* vibrationIntervalMsOut,
    int8_t* radioTxPowerDbmOut
  ) {
    if (!dlrIntervalMsOut || !vibrationIntervalMsOut || !radioTxPowerDbmOut) {
      return;
    }

    switch (currentMode) {
      case POWER_MODE_BURST:
        *dlrIntervalMsOut = 10000;       /* 10 seconds */
        *vibrationIntervalMsOut = 30000; /* 30 seconds */
        *radioTxPowerDbmOut = +10;       /* Max range +10 dBm */
        break;

      case POWER_MODE_CONTINUOUS:
        *dlrIntervalMsOut = 60000;       /* 1 minute */
        *vibrationIntervalMsOut = 300000;/* 5 minutes */
        *radioTxPowerDbmOut = 0;         /* Standard 0 dBm */
        break;

      case POWER_MODE_ECO:
        *dlrIntervalMsOut = 300000;       /* 5 minutes */
        *vibrationIntervalMsOut = 1800000;/* 30 minutes */
        *radioTxPowerDbmOut = -7;         /* Low power -7 dBm */
        break;

      case POWER_MODE_HIBERNATE:
      default:
        *dlrIntervalMsOut = 1800000;      /* 30 minutes */
        *vibrationIntervalMsOut = 7200000;/* 2 hours */
        *radioTxPowerDbmOut = -15;        /* Ultra-low -15 dBm */
        break;
    }
  }
}
