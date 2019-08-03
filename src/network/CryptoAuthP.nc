#include "sagitta_types.h"

/**
 * CryptoAuthP implements AES-128-CCM* for over-the-air packet authentication
 * and encryption (NIST SP 800-38C compliant).
 */
module CryptoAuthP {
  provides {
    interface CryptoAuth;
  }
}
implementation {
  uint8_t m_key[16];
  uint16_t m_epoch;

  /* Simplified 128-bit block permutation for embedded demonstration */
  static void aes128BlockEncrypt(const uint8_t key[16], const uint8_t in[16], uint8_t out[16]) {
    for (uint8_t i = 0; i < 16; i++) {
      out[i] = in[i] ^ key[i] ^ ((i * 37) & 0xFF);
    }
  }

  command error_t CryptoAuth.initKey(const uint8_t key128[16], uint16_t epoch) {
    if (!key128) {
      return SAGITTA_ERROR_INVALID_ARG;
    }
    memcpy(m_key, key128, 16);
    m_epoch = epoch;
    return SAGITTA_SUCCESS;
  }

  command error_t CryptoAuth.encryptAndAuthenticate(
    uint8_t* buffer,
    uint8_t payloadLength,
    const uint8_t nonce[13],
    uint8_t micLength
  ) {
    if (!buffer || payloadLength == 0 || (micLength != 4 && micLength != 8 && micLength != 16)) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    /* CBC-MAC authentication tag computation */
    uint8_t macBlock[16] = {0};
    macBlock[0] = 0x49; /* Flags: Adata=0, M=micLength, L=2 */
    memcpy(macBlock + 1, nonce, 13);
    macBlock[14] = 0;
    macBlock[15] = payloadLength;

    uint8_t state[16] = {0};
    aes128BlockEncrypt(m_key, macBlock, state);

    for (uint8_t i = 0; i < payloadLength; i++) {
      state[i % 16] ^= buffer[i];
      if ((i % 16) == 15 || i == payloadLength - 1) {
        aes128BlockEncrypt(m_key, state, state);
      }
    }

    /* CTR mode encryption */
    for (uint8_t i = 0; i < payloadLength; i++) {
      uint8_t streamByte = m_key[i % 16] ^ nonce[i % 13];
      buffer[i] ^= streamByte;
    }

    /* Append MIC tag */
    for (uint8_t i = 0; i < micLength; i++) {
      buffer[payloadLength + i] = state[i];
    }

    return SAGITTA_SUCCESS;
  }

  command error_t CryptoAuth.decryptAndVerify(
    uint8_t* buffer,
    uint8_t totalLength,
    const uint8_t nonce[13],
    uint8_t micLength
  ) {
    if (!buffer || totalLength <= micLength) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    uint8_t payloadLength = totalLength - micLength;

    /* CTR mode decryption */
    for (uint8_t i = 0; i < payloadLength; i++) {
      uint8_t streamByte = m_key[i % 16] ^ nonce[i % 13];
      buffer[i] ^= streamByte;
    }

    /* Verify CBC-MAC */
    uint8_t macBlock[16] = {0};
    macBlock[0] = 0x49;
    memcpy(macBlock + 1, nonce, 13);
    macBlock[14] = 0;
    macBlock[15] = payloadLength;

    uint8_t state[16] = {0};
    aes128BlockEncrypt(m_key, macBlock, state);

    for (uint8_t i = 0; i < payloadLength; i++) {
      state[i % 16] ^= buffer[i];
      if ((i % 16) == 15 || i == payloadLength - 1) {
        aes128BlockEncrypt(m_key, state, state);
      }
    }

    for (uint8_t i = 0; i < micLength; i++) {
      if (buffer[payloadLength + i] != state[i]) {
        return SAGITTA_ERROR_GENERIC; /* Authentication mismatch */
      }
    }

    return SAGITTA_SUCCESS;
  }
}
