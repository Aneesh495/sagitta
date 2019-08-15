#include <math.h>
#include "weather_generator.h"

void weather_generator_init_default(weather_profile_t* profile) {
  if (!profile) return;
  profile->ambient_temp_base_c = 22.0f;
  profile->ambient_temp_amplitude_c = 8.0f;
  profile->wind_speed_mean_mps = 3.5f;
  profile->wind_gust_amplitude_mps = 2.0f;
  profile->wind_yaw_mean_deg = 45.0f;
  profile->solar_flux_peak_wm2 = 900.0f;
  profile->diurnal_period_seconds = 86400.0f; /* 24 hours */
}

weather_snapshot_t weather_generator_sample(const weather_profile_t* profile, float sim_time_seconds) {
  weather_snapshot_t snap = {0};
  if (!profile) return snap;

  float phase = (2.0f * 3.14159265f * sim_time_seconds) / profile->diurnal_period_seconds;

  /* Ambient temperature: peak in afternoon (phase ~ pi/2) */
  snap.ambient_temp_c = profile->ambient_temp_base_c + profile->ambient_temp_amplitude_c * sinf(phase - 0.5f);

  /* Wind speed with synthetic gusts */
  float gustComponent = profile->wind_gust_amplitude_mps * sinf(phase * 12.0f) * cosf(phase * 3.7f);
  snap.wind_speed_mps = profile->wind_speed_mean_mps + gustComponent;
  if (snap.wind_speed_mps < 0.2f) snap.wind_speed_mps = 0.2f;

  /* Wind attack yaw */
  snap.wind_yaw_deg = profile->wind_yaw_mean_deg + 15.0f * sinf(phase * 4.0f);

  /* Solar radiation: positive during daylight hours */
  float sunElevation = sinf(phase);
  if (sunElevation > 0.0f) {
    snap.solar_flux_wm2 = profile->solar_flux_peak_wm2 * sunElevation;
  } else {
    snap.solar_flux_wm2 = 0.0f;
  }

  return snap;
}
