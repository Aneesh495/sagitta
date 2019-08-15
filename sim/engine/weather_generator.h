#ifndef WEATHER_GENERATOR_H
#define WEATHER_GENERATOR_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
  float ambient_temp_base_c;
  float ambient_temp_amplitude_c;
  float wind_speed_mean_mps;
  float wind_gust_amplitude_mps;
  float wind_yaw_mean_deg;
  float solar_flux_peak_wm2;
  float diurnal_period_seconds;
} weather_profile_t;

typedef struct {
  float ambient_temp_c;
  float wind_speed_mps;
  float wind_yaw_deg;
  float solar_flux_wm2;
} weather_snapshot_t;

void weather_generator_init_default(weather_profile_t* profile);
weather_snapshot_t weather_generator_sample(const weather_profile_t* profile, float sim_time_seconds);

#ifdef __cplusplus
}
#endif

#endif /* WEATHER_GENERATOR_H */
