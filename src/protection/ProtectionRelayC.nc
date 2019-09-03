#include "sagitta_types.h"

/**
 * ProtectionRelayC wires the complete ANSI protective relay suite:
 * ANSI 50 (Instantaneous Overcurrent), ANSI 51 (Time Overcurrent),
 * ANSI 21 (Distance), ANSI 27 (Undervoltage), ANSI 59 (Overvoltage),
 * ANSI 67 (Directional), ANSI 87 (Differential), and ANSI 25 (Synchrocheck).
 */
configuration ProtectionRelayC {
  provides {
    interface RelayProtection as Relay50;
    interface RelayProtection as Relay51;
    interface RelayProtection as Relay21;
    interface RelayProtection as Relay27;
    interface RelayProtection as Relay59;
    interface RelayProtection as Relay67;
    interface RelayProtection as Relay87;
    interface RelayProtection as Relay25;
  }
}
implementation {
  components InstantaneousOvercurrent50P;
  components TimeOvercurrent51P;
  components DistanceRelay21P;
  components UnderVoltage27P;
  components OverVoltage59P;
  components DirectionalRelay67P;
  components DifferentialRelay87P;
  components SynchroCheck25P;

  Relay50 = InstantaneousOvercurrent50P.Relay50;
  Relay51 = TimeOvercurrent51P.Relay51;
  Relay21 = DistanceRelay21P.Relay21;
  Relay27 = UnderVoltage27P.Relay27;
  Relay59 = OverVoltage59P.Relay59;
  Relay67 = DirectionalRelay67P.Relay67;
  Relay87 = DifferentialRelay87P.Relay87;
  Relay25 = SynchroCheck25P.Relay25;
}
