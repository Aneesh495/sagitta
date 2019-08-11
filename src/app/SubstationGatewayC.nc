#include "sagitta_types.h"

/**
 * SubstationGatewayC wires the substation sink gateway node.
 */
configuration SubstationGatewayC {
  provides {
    interface Init;
  }
}
implementation {
  components SubstationGatewayP;
  components CorridorRoutingC;
  components MacTschC;
  components TimeSyncC;
  components RadioDriverP;

  Init = SubstationGatewayP.Init;

  SubstationGatewayP.CorridorRouting -> CorridorRoutingC.CorridorRouting;
  SubstationGatewayP.MacTsch -> MacTschC.MacTsch;
  SubstationGatewayP.TimeSync -> TimeSyncC.TimeSync;

  MacTschC.RadioTransceiver -> RadioDriverP.RadioTransceiver;
  CorridorRoutingC.MacTsch -> MacTschC.MacTsch;
}
