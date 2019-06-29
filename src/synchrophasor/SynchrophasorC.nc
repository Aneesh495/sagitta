#include "sagitta_types.h"
#include "phasor_params.h"

/**
 * SynchrophasorC wires the PMU coordinator to recursive DFT,
 * frequency estimation, and ROCOF monitoring modules.
 */
configuration SynchrophasorC {
  provides {
    interface Synchrophasor;
    interface DftPhasor;
    interface FrequencyEstimator;
    interface RocofMonitor;
  }
}
implementation {
  components SynchrophasorP;
  components DftPhasorP;
  components FrequencyEstimatorP;
  components RocofMonitorP;

  Synchrophasor = SynchrophasorP.Synchrophasor;
  DftPhasor = DftPhasorP.DftPhasor;
  FrequencyEstimator = FrequencyEstimatorP.FrequencyEstimator;
  RocofMonitor = RocofMonitorP.RocofMonitor;

  SynchrophasorP.DftPhasor -> DftPhasorP.DftPhasor;
  SynchrophasorP.FrequencyEstimator -> FrequencyEstimatorP.FrequencyEstimator;
  SynchrophasorP.RocofMonitor -> RocofMonitorP.RocofMonitor;
}
