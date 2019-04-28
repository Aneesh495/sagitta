#include "sagitta_types.h"
#include "phasor_params.h"
#include "sagitta_messages.h"

/**
 * Synchrophasor interface manages synchronized phasor acquisition,
 * IEEE C37.118 compliance, and time-stamped synchrophasor streaming.
 */
interface Synchrophasor {
  /**
   * Configures PMU parameters and reporting rate.
   * @param config Synchrophasor configuration settings
   * @return SUCCESS if valid
   */
  command error_t configure(const synchrophasor_config_t* config);

  /**
   * Pushes raw instantaneous voltage and current ADC samples.
   * @param rawVoltageSample Scaled instantaneous voltage sample
   * @param rawCurrentSample Scaled instantaneous current sample
   * @param timestamp Microsecond precision timestamp of sample
   * @return SUCCESS if pushed, EBUSY if processing frame
   */
  command error_t pushSamplePair(
    int16_t rawVoltageSample,
    int16_t rawCurrentSample,
    const sagitta_timestamp_t* timestamp
  );

  /**
   * Event signaled when a synchronized phasor frame is computed.
   * @param pmuFrame Pointer to completed C37.118 synchrophasor frame
   */
  event void phasorFrameReady(const msg_synchrophasor_t* pmuFrame);
}
