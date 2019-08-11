#include "sagitta_types.h"

/**
 * SagittaNodeC is the master configuration for an autonomous
 * transmission line monitoring mote.
 */
configuration SagittaNodeC {
  provides {
    interface Init;
  }
}
implementation {
  components SagittaNodeP;
  components DynamicLineRatingC;
  components CatenarySagC;
  components VibrationAnalysisC;
  components SynchrophasorC;
  components TravellingWaveC;
  components EnergyHarvestC;
  components MacTschC;
  components TimeSyncC;
  components CorridorRoutingC;
  components WatchdogTimerP;
  components RadioDriverP;

  Init = SagittaNodeP.Init;

  SagittaNodeP.DynamicLineRating -> DynamicLineRatingC.DynamicLineRating;
  SagittaNodeP.CatenarySag -> CatenarySagC.CatenarySag;
  SagittaNodeP.TiltToSag -> CatenarySagC.TiltToSag;
  SagittaNodeP.GroundClearance -> CatenarySagC.GroundClearance;
  SagittaNodeP.IceAccretion -> CatenarySagC.IceAccretion;
  SagittaNodeP.VibrationAnalysis -> VibrationAnalysisC.VibrationAnalysis;
  SagittaNodeP.Synchrophasor -> SynchrophasorC.Synchrophasor;
  SagittaNodeP.TravellingWave -> TravellingWaveC.TravellingWave;
  SagittaNodeP.EnergyHarvest -> EnergyHarvestC.EnergyHarvest;
  SagittaNodeP.MacTsch -> MacTschC.MacTsch;
  SagittaNodeP.TimeSync -> TimeSyncC.TimeSync;
  SagittaNodeP.CorridorRouting -> CorridorRoutingC.CorridorRouting;
  SagittaNodeP.WatchdogSuper -> WatchdogTimerP.WatchdogSuper;

  MacTschC.RadioTransceiver -> RadioDriverP.RadioTransceiver;
  CorridorRoutingC.MacTsch -> MacTschC.MacTsch;
}
