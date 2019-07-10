#include "sagitta_types.h"
#include "wavefront_params.h"

/**
 * TravellingWaveC wires the wavefront capture, double-ended TWFL solver,
 * Bewley reflection analyzer, and surge classifier modules.
 */
configuration TravellingWaveC {
  provides {
    interface TravellingWave;
    interface WavefrontCapture;
    interface DoubleEndedTwfl;
    interface BewleyLattice;
    interface SurgeClassifier;
  }
}
implementation {
  components TravellingWaveP;
  components WavefrontCaptureP;
  components DoubleEndedTwflP;
  components BewleyLatticeP;
  components SurgeClassifierP;

  TravellingWave = TravellingWaveP.TravellingWave;
  WavefrontCapture = WavefrontCaptureP.WavefrontCapture;
  DoubleEndedTwfl = DoubleEndedTwflP.DoubleEndedTwfl;
  BewleyLattice = BewleyLatticeP.BewleyLattice;
  SurgeClassifier = SurgeClassifierP.SurgeClassifier;

  TravellingWaveP.WavefrontCapture -> WavefrontCaptureP.WavefrontCapture;
  TravellingWaveP.DoubleEndedTwfl -> DoubleEndedTwflP.DoubleEndedTwfl;
  TravellingWaveP.BewleyLattice -> BewleyLatticeP.BewleyLattice;
  TravellingWaveP.SurgeClassifier -> SurgeClassifierP.SurgeClassifier;
}
