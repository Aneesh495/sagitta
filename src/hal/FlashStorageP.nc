#include "sagitta_types.h"

#define FLASH_CIRCULAR_BUFFER_SIZE 4096

/**
 * FlashStorageP implements a wear-levelled non-volatile circular event log.
 */
module FlashStorageP {
  provides {
    interface NonVolatileLog;
  }
}
implementation {
  uint8_t m_storageBuffer[FLASH_CIRCULAR_BUFFER_SIZE];
  uint16_t m_writePtr;
  uint16_t m_readPtr;

  command error_t NonVolatileLog.writeRecord(uint8_t recordType, const uint8_t* data, uint8_t length) {
    if (!data || length == 0 || length > 250) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    uint16_t totalLen = length + 2;
    if (m_writePtr + totalLen >= FLASH_CIRCULAR_BUFFER_SIZE) {
      m_writePtr = 0; /* Wrap circular buffer */
    }

    m_storageBuffer[m_writePtr++] = recordType;
    m_storageBuffer[m_writePtr++] = length;
    memcpy(m_storageBuffer + m_writePtr, data, length);
    m_writePtr += length;

    return SAGITTA_SUCCESS;
  }

  command error_t NonVolatileLog.readNextRecord(uint8_t* buffer, uint8_t maxLen, uint8_t* actualLenOut) {
    if (!buffer || !actualLenOut) {
      return SAGITTA_ERROR_INVALID_ARG;
    }
    if (m_readPtr == m_writePtr) {
      return SAGITTA_ERROR_NOT_FOUND;
    }

    uint8_t type = m_storageBuffer[m_readPtr++];
    uint8_t len = m_storageBuffer[m_readPtr++];
    uint8_t copyLen = (len < maxLen) ? len : maxLen;

    memcpy(buffer, m_storageBuffer + m_readPtr, copyLen);
    m_readPtr += len;
    *actualLenOut = copyLen;

    return SAGITTA_SUCCESS;
  }
}
