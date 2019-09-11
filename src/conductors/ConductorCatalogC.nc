#include "sagitta_types.h"
#include "conductor_params.h"

/**
 * ConductorCatalogC wires the transmission conductor library components.
 */
configuration ConductorCatalogC {
  provides {
    interface ConductorProfile as Drake;
    interface ConductorProfile as Grosbeak;
    interface ConductorProfile as Cardinal;
    interface ConductorProfile as Curlew;
    interface ConductorProfile as Rail;
    interface ConductorProfile as Hawk;
    interface ConductorProfile as Finch;
    interface ConductorProfile as Falcon;
  }
}
implementation {
  components AcsrDrakeP;
  components AcsrGrosbeakP;
  components AcsrCardinalP;
  components AcssCurlewP;
  components AcsrRailP;
  components AcsrHawkP;
  components AcsrFinchP;
  components AcsrFalconP;

  Drake = AcsrDrakeP.Drake;
  Grosbeak = AcsrGrosbeakP.Grosbeak;
  Cardinal = AcsrCardinalP.Cardinal;
  Curlew = AcssCurlewP.Curlew;
  Rail = AcsrRailP.Rail;
  Hawk = AcsrHawkP.Hawk;
  Finch = AcsrFinchP.Finch;
  Falcon = AcsrFalconP.Falcon;
}
