#ifndef TEST_RUNNER_H
#define TEST_RUNNER_H

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>

#ifdef __cplusplus
extern "C" {
#endif

extern int g_tests_run;
extern int g_tests_passed;
extern int g_tests_failed;

#define TEST_ASSERT(cond) do { \
  g_tests_run++; \
  if (!(cond)) { \
    printf("  [FAIL] %s:%d: Assertion failed: %s\n", __FILE__, __LINE__, #cond); \
    g_tests_failed++; \
    return false; \
  } else { \
    g_tests_passed++; \
  } \
} while (0)

#define TEST_ASSERT_NEAR(a, b, eps) do { \
  g_tests_run++; \
  float _diff = fabsf((float)(a) - (float)(b)); \
  if (_diff > (float)(eps)) { \
    printf("  [FAIL] %s:%d: Assertion failed: |%s - %s| = %f > %f (actual: %f, expected: %f)\n", \
           __FILE__, __LINE__, #a, #b, _diff, (float)(eps), (float)(a), (float)(b)); \
    g_tests_failed++; \
    return false; \
  } else { \
    g_tests_passed++; \
  } \
} while (0)

#define TEST_ASSERT_EQUAL_INT(a, b) do { \
  g_tests_run++; \
  if ((a) != (b)) { \
    printf("  [FAIL] %s:%d: Assertion failed: %s == %s (actual: %d, expected: %d)\n", \
           __FILE__, __LINE__, #a, #b, (int)(a), (int)(b)); \
    g_tests_failed++; \
    return false; \
  } else { \
    g_tests_passed++; \
  } \
} while (0)

typedef bool (*test_func_t)(void);

void run_test(const char* name, test_func_t func);

#ifdef __cplusplus
}
#endif

#endif /* TEST_RUNNER_H */
