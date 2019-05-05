#include "sagitta_types.h"

/**
 * CryptoAuth interface provides authenticated encryption and decryption
 * using AES-128-CCM* for over-the-air packet protection.
 */
interface CryptoAuth {
  /**
   * Initializes master session key and security epoch counter.
   * @param key128 16-byte cryptographic key
   * @param epoch 16-bit epoch identifier
   * @return SUCCESS if initialized
   */
  command error_t initKey(const uint8_t key128[16], uint16_t epoch);

  /**
   * Encrypts and authenticates a plaintext buffer in-place using AES-128-CCM*.
   * @param buffer Payload buffer (must have room for MIC tag)
   * @param payloadLength Plaintext byte length
   * @param nonce Nonce array (13 bytes)
   * @param micLength MAC tag length (4, 8, or 16 bytes)
   * @return SUCCESS if encrypted and authenticated
   */
  command error_t encryptAndAuthenticate(
    uint8_t* buffer,
    uint8_t payloadLength,
    const uint8_t nonce[13],
    uint8_t micLength
  );

  /**
   * Decrypts and verifies a ciphertext buffer in-place.
   * @param buffer Encrypted payload buffer including MIC
   * @param totalLength Total buffer length including MIC
   * @param nonce Nonce array (13 bytes)
   * @param micLength MAC tag length
   * @return SUCCESS if verification passed, FAIL if authentication failed
   */
  command error_t decryptAndVerify(
    uint8_t* buffer,
    uint8_t totalLength,
    const uint8_t nonce[13],
    uint8_t micLength
  );
}
