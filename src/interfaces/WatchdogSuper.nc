#include "sagitta_types.h"

/**
 * WatchdogSuper interface supervises task execution and kicks hardware watchdog.
 */
interface WatchdogSuper {
  /**
   * Kicks the hardware watchdog timer.
   */
  async command void kick();

  /**
   * Registers a task execution checkpoint.
   * @param taskId Task identifier
   */
  command void reportAlive(uint8_t taskId);

  /**
   * Event signaled if a task starves or exceeds deadline.
   * @param taskId Starved task identifier
   */
  event void taskStarved(uint8_t taskId);
}
