#ifndef SAGITTA_TYPES_H
#define SAGITTA_TYPES_H

#include <stdint.h>
#include <stdbool.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifndef TRUE
#define TRUE 1
#endif
#ifndef FALSE
#define FALSE 0
#endif

/*
 * Sagitta Error Codes
 */
typedef enum {
  SAGITTA_SUCCESS          = 0,
  SAGITTA_ERROR_GENERIC    = 1,
  SAGITTA_ERROR_INVALID_ARG = 2,
  SAGITTA_ERROR_BUSY       = 3,
  SAGITTA_ERROR_TIMEOUT    = 4,
  SAGITTA_ERROR_OVERFLOW   = 5,
  SAGITTA_ERROR_UNDERFLOW  = 6,
  SAGITTA_ERROR_NOT_FOUND  = 7,
  SAGITTA_ERROR_ALREADY    = 8,
  SAGITTA_ERROR_HW_FAULT   = 9,
  SAGITTA_ERROR_LOW_POWER  = 10
} sagitta_error_t;

/*
 * Fixed-point mathematical representations:
 * Q15: 1 sign bit, 15 fractional bits (-1.0 to +0.999969)
 * Q31: 1 sign bit, 31 fractional bits
 * Q8_8: 8 integer bits, 8 fractional bits
 * Q16_16: 16 integer bits, 16 fractional bits
 */
typedef int16_t q15_t;
typedef int32_t q31_t;
typedef int16_t q8_8_t;
typedef int32_t q16_16_t;

#define Q15_ONE          ((q15_t)32767)
#define Q15_MIN          ((q15_t)-32768)
#define Q31_ONE          ((q31_t)2147483647L)
#define Q31_MIN          ((q31_t)-2147483648L)

#define FLOAT_TO_Q15(f)  ((q15_t)((f) * 32767.0f))
#define Q15_TO_FLOAT(q)  (((float)(q)) / 32767.0f)

#define FLOAT_TO_Q31(f)  ((q31_t)((f) * 2147483647.0f))
#define Q31_TO_FLOAT(q)  (((float)(q)) / 2147483647.0f)

#define FLOAT_TO_Q16_16(f) ((q16_16_t)((f) * 65536.0f))
#define Q16_16_TO_FLOAT(q) (((float)(q)) / 65536.0f)

/*
 * Transmission Phase Identifier
 */
typedef enum {
  PHASE_A = 0,
  PHASE_B = 1,
  PHASE_C = 2,
  PHASE_GROUND_WIRE = 3
} phase_id_t;

/*
 * Mote Operational Power Mode
 */
typedef enum {
  POWER_MODE_HIBERNATE  = 0, /* Low capacitor reserve, periodic beacon only */
  POWER_MODE_ECO        = 1, /* Basic 5-minute thermal and tilt check */
  POWER_MODE_CONTINUOUS = 2, /* 1-minute DLR, periodic vibration FFT */
  POWER_MODE_BURST      = 3  /* Real-time synchrophasor and high-rate surveillance */
} power_mode_t;

/*
 * Grid Alarm Severity Flags
 */
typedef enum {
  ALARM_LEVEL_NORMAL    = 0,
  ALARM_LEVEL_ADVISORY  = 1,
  ALARM_LEVEL_WARNING   = 2,
  ALARM_LEVEL_CRITICAL  = 3,
  ALARM_LEVEL_EMERGENCY = 4
} alarm_level_t;

/*
 * Global Microsecond Precision Timestamp
 */
typedef struct {
  uint32_t seconds;
  uint32_t microseconds;
} sagitta_timestamp_t;

#ifdef __cplusplus
}
#endif

#endif /* SAGITTA_TYPES_H */
