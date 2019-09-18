#include "sagitta_types.h"

/**
 * DigitalFilter interface abstracts IIR and FIR digital signal processing filters.
 */
interface DigitalFilter {
  /**
   * Resets internal filter delay lines and history buffers to zero.
   */
  command void resetFilter();

  /**
   * Processes a single input sample through the filter structure.
   * @param inputSample 16-bit input sample in Q15 format
   * @return Filtered output sample in Q15 format
   */
  command q15_t filterSample(q15_t inputSample);

  /**
   * Filters an array of contiguous samples in-place.
   * @param buffer Array of samples in Q15
   * @param count Number of samples
   */
  command void filterBlock(q15_t* buffer, uint16_t count);
}
