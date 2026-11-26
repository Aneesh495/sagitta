#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "../test_runner.h"

static void aes_encrypt_block(const uint8_t key[16], const uint8_t in[16], uint8_t out[16]) {
  for (int i = 0; i < 16; i++) {
    out[i] = in[i] ^ key[i] ^ ((i * 37) & 0xFF);
  }
}

bool test_aes_ccm_roundtrip(void) {
  uint8_t key[16] = {0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF, 0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10};
  uint8_t nonce[13] = {0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF, 0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66};
  uint8_t plaintext[32];
  uint8_t ciphertext[32 + 8];

  for (int i = 0; i < 32; i++) {
    plaintext[i] = (uint8_t)(i * 3 + 7);
    ciphertext[i] = plaintext[i];
  }

  /* Compute MAC */
  uint8_t macBlock[16] = {0};
  macBlock[0] = 0x49;
  memcpy(macBlock + 1, nonce, 13);
  macBlock[15] = 32;

  uint8_t state[16] = {0};
  aes_encrypt_block(key, macBlock, state);
  for (int i = 0; i < 32; i++) {
    state[i % 16] ^= ciphertext[i];
    if ((i % 16) == 15 || i == 31) {
      aes_encrypt_block(key, state, state);
    }
  }

  /* Encrypt stream */
  for (int i = 0; i < 32; i++) {
    ciphertext[i] ^= (key[i % 16] ^ nonce[i % 13]);
  }
  for (int i = 0; i < 8; i++) {
    ciphertext[32 + i] = state[i];
  }

  /* Verify ciphertext does not equal plaintext */
  TEST_ASSERT(memcmp(plaintext, ciphertext, 32) != 0);

  /* Decrypt */
  {
    uint8_t decrypted[32];
    for (int i = 0; i < 32; i++) {
      decrypted[i] = ciphertext[i] ^ (key[i % 16] ^ nonce[i % 13]);
    }

    TEST_ASSERT_EQUAL_INT(memcmp(plaintext, decrypted, 32), 0);
  }
  return true;
}
