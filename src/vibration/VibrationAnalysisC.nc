#include "sagitta_types.h"
#include "vibration_params.h"

/**
 * VibrationAnalysisC wires the FFT transformation, modal bending strain,
 * galloping detector, and cumulative fatigue tracking modules.
 */
configuration VibrationAnalysisC {
  provides {
    interface VibrationAnalysis;
    interface FastFourierTransform;
    interface ModalBending;
    interface GallopingDetector;
    interface FatigueLife;
  }
}
implementation {
  components VibrationAnalysisP;
  components FastFourierTransformP;
  components ModalBendingP;
  components GallopingDetectorP;
  components FatigueLifeP;

  VibrationAnalysis = VibrationAnalysisP.VibrationAnalysis;
  FastFourierTransform = FastFourierTransformP.FastFourierTransform;
  ModalBending = ModalBendingP.ModalBending;
  GallopingDetector = GallopingDetectorP.GallopingDetector;
  FatigueLife = FatigueLifeP.FatigueLife;

  VibrationAnalysisP.FastFourierTransform -> FastFourierTransformP.FastFourierTransform;
  VibrationAnalysisP.ModalBending -> ModalBendingP.ModalBending;
  VibrationAnalysisP.GallopingDetector -> GallopingDetectorP.GallopingDetector;
  VibrationAnalysisP.FatigueLife -> FatigueLifeP.FatigueLife;
}
