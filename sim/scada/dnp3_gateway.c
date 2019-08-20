#include <stdio.h>
#include <string.h>
#include "dnp3_gateway.h"

void dnp3_gateway_init(dnp3_outstation_t* outstation) {
  if (!outstation) return;
  memset(outstation, 0, sizeof(dnp3_outstation_t));
  outstation->analog_point_count = 0;
  outstation->binary_point_count = 0;
  outstation->scada_frames_transmitted = 0;
}

void dnp3_gateway_update(dnp3_outstation_t* outstation, const sagitta_simulation_t* sim) {
  if (!outstation || !sim) return;

  uint16_t aIdx = 0;
  uint16_t bIdx = 0;
  uint64_t nowMs = (uint64_t)(sim->sim_time_seconds * 1000.0f);

  for (uint16_t i = 0; i < sim->corridor.mote_count && aIdx < 250 && bIdx < 60; i++) {
    const sim_mote_state_t* m = &sim->corridor.motes[i];

    /* Analog Point 0: Conductor Temperature (deg C) */
    outstation->analog_points[aIdx].point_index = aIdx;
    outstation->analog_points[aIdx].value = m->conductor_temp_c;
    outstation->analog_points[aIdx].flags = 0x01; /* ONLINE */
    outstation->analog_points[aIdx].timestamp_ms = nowMs;
    aIdx++;

    /* Analog Point 1: Mid-Span Sagitta (meters) */
    outstation->analog_points[aIdx].point_index = aIdx;
    outstation->analog_points[aIdx].value = m->midspan_sag_m;
    outstation->analog_points[aIdx].flags = 0x01;
    outstation->analog_points[aIdx].timestamp_ms = nowMs;
    aIdx++;

    /* Analog Point 2: Minimum Ground Clearance (meters) */
    outstation->analog_points[aIdx].point_index = aIdx;
    outstation->analog_points[aIdx].value = m->min_ground_clearance_m;
    outstation->analog_points[aIdx].flags = 0x01;
    outstation->analog_points[aIdx].timestamp_ms = nowMs;
    aIdx++;

    /* Analog Point 3: Mechanical Tension (Newtons) */
    outstation->analog_points[aIdx].point_index = aIdx;
    outstation->analog_points[aIdx].value = m->mechanical_tension_n;
    outstation->analog_points[aIdx].flags = 0x01;
    outstation->analog_points[aIdx].timestamp_ms = nowMs;
    aIdx++;

    /* Binary Point 0: Thermal Warning Alarm */
    outstation->binary_points[bIdx].point_index = bIdx;
    outstation->binary_points[bIdx].state = (m->conductor_temp_c >= 75.0f);
    outstation->binary_points[bIdx].flags = 0x01;
    bIdx++;

    /* Binary Point 1: Statutory Clearance Breach Alarm */
    outstation->binary_points[bIdx].point_index = bIdx;
    outstation->binary_points[bIdx].state = (m->min_ground_clearance_m < 7.5f);
    outstation->binary_points[bIdx].flags = 0x01;
    bIdx++;
  }

  outstation->analog_point_count = aIdx;
  outstation->binary_point_count = bIdx;
  outstation->scada_frames_transmitted++;
}

uint16_t dnp3_gateway_export_frame(const dnp3_outstation_t* outstation, uint8_t* frame_buffer, uint16_t max_len) {
  if (!outstation || !frame_buffer || max_len < 10) return 0;

  /* Standard DNP3 Link Layer Header (10 bytes):
   * 0x05, 0x64 (Start bytes), Length, Control, Dest, Source, CRC16
   */
  frame_buffer[0] = 0x05;
  frame_buffer[1] = 0x64;
  frame_buffer[2] = 0x14; /* Length */
  frame_buffer[3] = 0xC4; /* Master-to-Outstation primary link */
  frame_buffer[4] = 0x01; /* Dest LSB */
  frame_buffer[5] = 0x00; /* Dest MSB */
  frame_buffer[6] = 0x0A; /* Source LSB */
  frame_buffer[7] = 0x00; /* Source MSB */
  frame_buffer[8] = 0xDE; /* CRC LSB */
  frame_buffer[9] = 0xAD; /* CRC MSB */

  return 10;
}
