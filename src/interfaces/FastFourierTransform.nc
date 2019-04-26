#include "sagitta_types.h"

/**
 * FastFourierTransform interface provides in-place fixed-point FFT
 * transformation for embedded signal processing.
 */
interface FastFourierTransform {
  /**
   * Applies a 16-bit Hann window in-place to the real sample buffer.
   * @param realBuffer Real input samples in Q15 format
   * @param length Number of samples (must be power of 2)
   */
  command void applyHannWindow(q15_t* realBuffer, uint16_t length);

  /**
   * Performs an in-place Radix-2 Decimation-In-Time complex FFT.
   * @param realBuffer Real component buffer in Q15 format
   * @param imagBuffer Imaginary component buffer in Q15 format (initially zero)
   * @param length Number of points (power of 2, e.g., 256)
   * @return SUCCESS if completed, EINVAL if length invalid
   */
  command error_t transformRadix2(q15_t* realBuffer, q15_t* imagBuffer, uint16_t length);

  /**
   * Computes power spectral magnitude squared for each frequency bin.
   * @param realBuffer Real output of FFT
   * @param imagBuffer Imaginary output of FFT
   * @param powerOut Output power spectrum buffer (length / 2 entries)
   * @param length Total FFT point count
   */
  command void computePowerSpectrum(
    const q15_t* realBuffer,
    const q15_t* imagBuffer,
    uint32_t* powerOut,
    uint16_t length
  );

  /**
   * Identifies the primary spectral resonance peak in the power spectrum.
   * @param powerSpectrum Array of power magnitudes
   * @param numBins Number of frequency bins (length / 2)
   * @param sampleRateHz Sampling frequency in Hertz
   * @param peakFreqHzOut Pointer to store dominant peak frequency (Hz)
   * @param peakPowerOut Pointer to store peak spectral magnitude
   */
  command void findPeakFrequency(
    const uint32_t* powerSpectrum,
    uint16_t numBins,
    float sampleRateHz,
    float* peakFreqHzOut,
    uint32_t* peakPowerOut
  );
}
