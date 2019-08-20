#!/usr/bin/env python3
"""EPRI and CIGRE meteorological and contingency test profile generator."""

import json
import math
import sys

def generate_diurnal_profile(hours=24, step_seconds=60):
    steps = int(hours * 3600 / step_seconds)
    records = []

    for s in range(steps):
        t_sec = s * step_seconds
        phase = (2.0 * math.pi * t_sec) / 86400.0

        amb_temp = 22.0 + 8.0 * math.sin(phase - 0.5)
        wind_speed = 3.5 + 1.5 * math.sin(phase * 10.0)
        if wind_speed < 0.3:
            wind_speed = 0.3

        sun_elev = math.sin(phase)
        solar_flux = max(0.0, 950.0 * sun_elev)
        load_current = 650.0 + 250.0 * max(0.0, math.sin(phase))

        records.append({
            "time_seconds": t_sec,
            "ambient_temp_c": round(amb_temp, 2),
            "wind_speed_mps": round(wind_speed, 2),
            "solar_flux_wm2": round(solar_flux, 1),
            "line_current_a": round(load_current, 1)
        })

    return records

def main():
    profile = generate_diurnal_profile()
    if len(sys.argv) > 1 and sys.argv[1] == "--summary":
        print(f"Generated {len(profile)} time-series steps for 24-hour diurnal cycle.")
        print(f"Sample step 0: {profile[0]}")
        print(f"Sample peak step (noon): {profile[len(profile)//2]}")
    else:
        print(json.dumps(profile[:10], indent=2))

if __name__ == "__main__":
    main()
