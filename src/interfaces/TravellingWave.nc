#include "sagitta_types.h"
#include "wavefront_params.h"
#include "sagitta_messages.h"

/**
 * TravellingWave interface coordinates high-speed transient detection,
 * wavefront capture, and fault distance localization across spans.
 */
interface TravellingWave {
  /**
   * Configures travelling wave front-end and detection parameters.
   * @param config Wavefront capture and propagation configuration
   * @return SUCCESS if valid
   */
  command error_t configure(const wavefront_config_t* config);

  /**
   * Arms the high-speed analog comparator and DMA ring buffer for transient capture.
   * @return SUCCESS if armed, EALREADY if already armed
   */
  command error_t armWavefrontTrigger();

  /**
   * Event signaled when a high-voltage travelling wavefront is captured.
   * @param eventData Pointer to captured wavefront event record
   */
  event void wavefrontCaptured(const msg_wavefront_event_t* eventData);
}
