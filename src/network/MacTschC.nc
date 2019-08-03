#include "sagitta_types.h"

/**
 * MacTschC wires TSCH MAC protocol engine to the hardware radio driver.
 */
configuration MacTschC {
  provides {
    interface MacTsch;
  }
  uses {
    interface RadioTransceiver;
  }
}
implementation {
  components MacTschP;
  MacTsch = MacTschP.MacTsch;
  MacTschP.RadioTransceiver = RadioTransceiver;
}
