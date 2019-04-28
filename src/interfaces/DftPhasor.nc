#include "sagitta_types.h"
#include "phasor_params.h"

/**
 * DftPhasor interface computes recursive Discrete Fourier Transform
 * to extract fundamental voltage and current phasor magnitude and phase.
 */
interface DftPhasor {
  /**
   * Initializes DFT sliding window buffers.
   * @param windowLength Number of samples per fundamental cycle (e.g., 64)
   * @return SUCCESS if initialized
   */
  command error_t initDft(uint16_t windowLength);

  /**
   * Updates recursive DFT with one new sample and removes oldest sample.
   * @param newSample New instantaneous sample value
   * @param oldSample Outgoing sample value from window end
   * @param realOut Pointer to store updated real phasor component
   * @param imagOut Pointer to store updated imaginary phasor component
   */
  command void updateRecursiveDft(
    int16_t newSample,
    int16_t oldSample,
    int32_t* realOut,
    int32_t* imagOut
  );

  /**
   * Computes RMS magnitude and phase angle from real/imag components.
   * @param realComponent Real phasor component
   * @param imagComponent Imaginary phasor component
   * @param magnitudeRmsOut Pointer to store RMS magnitude
   * @param phaseAngleRadOut Pointer to store phase angle in radians
   */
  command void computeMagnitudeAndPhase(
    int32_t realComponent,
    int32_t imagComponent,
    float* magnitudeRmsOut,
    float* phaseAngleRadOut
  );
}
