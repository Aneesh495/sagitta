#ifndef DNP3_GATEWAY_H
#define DNP3_GATEWAY_H

#include <stdint.h>
#include <stdbool.h>
#include "../engine/sagitta_sim.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
  uint16_t point_index;
  float value;
  uint8_t flags; /* DNP3 online / restart / fault flags */
  uint64_t timestamp_ms;
} dnp3_analog_point_t;

typedef struct {
  uint16_t point_index;
  bool state;
  uint8_t flags;
} dnp3_binary_point_t;

typedef struct {
  uint16_t analog_point_count;
  dnp3_analog_point_t analog_points[256];
  uint16_t binary_point_count;
  dnp3_binary_point_t binary_points[64];
  uint32_t scada_frames_transmitted;
} dnp3_outstation_t;

void dnp3_gateway_init(dnp3_outstation_t* outstation);
void dnp3_gateway_update(dnp3_outstation_t* outstation, const sagitta_simulation_t* sim);
uint16_t dnp3_gateway_export_frame(const dnp3_outstation_t* outstation, uint8_t* frame_buffer, uint16_t max_len);

#ifdef __cplusplus
}
#endif

#endif /* DNP3_GATEWAY_H */
