#include "sagitta_types.h"

/**
 * WaveletTransform interface provides multi-resolution Daubechies D4
 * discrete wavelet decomposition for transient edge and singularity extraction.
 */
interface WaveletTransform {
  /**
   * Performs 1-level forward discrete wavelet transform (DWT).
   * @param input Real input samples in Q15 format (length N)
   * @param approxOut Pointer to approximation coefficients (length N/2)
   * @param detailOut Pointer to detail coefficients (length N/2)
   * @param length Input length (must be even)
   * @return SUCCESS if decomposed
   */
  command error_t forwardDwt(
    const q15_t* input,
    q15_t* approxOut,
    q15_t* detailOut,
    uint16_t length
  );

  /**
   * Performs 1-level inverse discrete wavelet transform (IDWT).
   * @param approx Approximation coefficients (length N/2)
   * @param detail Detail coefficients (length N/2)
   * @param output Reconstructed sample buffer (length N)
   * @param length Reconstructed length
   * @return SUCCESS if reconstructed
   */
  command error_t inverseDwt(
    const q15_t* approx,
    const q15_t* detail,
    q15_t* output,
    uint16_t length
  );
}
