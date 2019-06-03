#include "sagitta_types.h"
#include "catenary_params.h"
#include "conductor_params.h"

/**
 * CatenarySagC wires catenary solver, tilt-to-sag converter, ice accretion estimator,
 * state change tension tracker, and ground clearance monitor.
 */
configuration CatenarySagC {
  provides {
    interface CatenarySag;
    interface TiltToSag;
    interface IceAccretion;
    interface TensionTracker;
    interface GroundClearance;
  }
}
implementation {
  components CatenarySagP;
  components TiltToSagP;
  components IceAccretionP;
  components TensionTrackerP;
  components GroundClearanceP;

  CatenarySag = CatenarySagP.CatenarySag;
  TiltToSag = TiltToSagP.TiltToSag;
  IceAccretion = IceAccretionP.IceAccretion;
  TensionTracker = TensionTrackerP.TensionTracker;
  GroundClearance = GroundClearanceP.GroundClearance;

  GroundClearanceP.CatenarySag -> CatenarySagP.CatenarySag;
  IceAccretionP.TensionTracker -> TensionTrackerP.TensionTracker;
}
