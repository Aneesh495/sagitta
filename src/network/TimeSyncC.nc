#include "sagitta_types.h"

/**
 * TimeSyncC provides network time synchronization via FTSP.
 */
configuration TimeSyncC {
  provides {
    interface TimeSync;
  }
}
implementation {
  components TimeSyncP;
  TimeSync = TimeSyncP.TimeSync;
}
