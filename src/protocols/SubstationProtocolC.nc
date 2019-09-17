#include "sagitta_types.h"

/**
 * SubstationProtocolC wires all substation automation protocol framers:
 * IEC 61850 GOOSE, IEC 61850 Sampled Values, IEEE C37.118-2011, DNP3, and Modbus RTU.
 */
configuration SubstationProtocolC {
  provides {
    interface ProtocolFramer as GooseFramer;
    interface ProtocolFramer as SvFramer;
    interface ProtocolFramer as C37118Framer;
    interface ProtocolFramer as Dnp3Framer;
    interface ProtocolFramer as ModbusFramer;
  }
}
implementation {
  components Iec61850GooseP;
  components Iec61850SvP;
  components C37118FramerP;
  components Dnp3OutstationP;
  components ModbusRtuP;

  GooseFramer = Iec61850GooseP.GooseFramer;
  SvFramer = Iec61850SvP.SvFramer;
  C37118Framer = C37118FramerP.C37118Framer;
  Dnp3Framer = Dnp3OutstationP.Dnp3Framer;
  ModbusFramer = ModbusRtuP.ModbusFramer;
}
