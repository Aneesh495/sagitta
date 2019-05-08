#include "sagitta_types.h"

/**
 * NonVolatileLog interface provides circular wear-levelled logging
 * in on-board SPI/I2C Flash for black-box fault recording.
 */
interface NonVolatileLog {
  /**
   * Writes a record into the circular flight recorder log.
   * @param recordType Type identifier for record
   * @param data Payload bytes
   * @param length Byte length of data
   * @return SUCCESS if written
   */
  command error_t writeRecord(uint8_t recordType, const uint8_t* data, uint8_t length);

  /**
   * Reads the oldest or newest unread record from storage.
   * @param buffer Output buffer
   * @param maxLen Buffer capacity
   * @param actualLenOut Pointer to store actual read length
   * @return SUCCESS if read, ENOENT if log empty
   */
  command error_t readNextRecord(uint8_t* buffer, uint8_t maxLen, uint8_t* actualLenOut);
}
