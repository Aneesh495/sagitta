#include "sagitta_types.h"

/**
 * CorridorRoutingC wires linear corridor collection tree routing to MAC TSCH.
 */
configuration CorridorRoutingC {
  provides {
    interface CorridorRouting;
  }
  uses {
    interface MacTsch;
  }
}
implementation {
  components CorridorRoutingP;
  CorridorRouting = CorridorRoutingP.CorridorRouting;
  CorridorRoutingP.MacTsch = MacTsch;
}
