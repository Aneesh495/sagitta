#ifndef SAGITTA_MESSAGES_H
#define SAGITTA_MESSAGES_H

#include "sagitta_types.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Message Protocol Identifiers */
typedef enum {
  MSG_TYPE_HEARTBEAT         = 0x01,
  MSG_TYPE_DLR_STATE         = 0x02,
  MSG_TYPE_CATENARY_STATE    = 0x03,
  MSG_TYPE_VIBRATION_ALERT   = 0x04,
  MSG_TYPE_SYNCHROPHASOR     = 0x05,
  MSG_TYPE_WAVEFRONT_EVENT   = 0x06,
  MSG_TYPE_TIME_SYNC         = 0x07,
  MSG_TYPE_COMMAND_CONFIG    = 0x08,
  MSG_TYPE_SCADA_EXPORT      = 0x09
} msg_type_t;

/* Header common to all over-the-air packets */
typedef struct __attribute__((packed)) {
  uint8_t  magic;          /* Protocol magic: 0x53 ('S') */
  uint8_t  version;        /* Protocol version: 1 */
  uint8_t  msg_type;       /* msg_type_t */
  uint8_t  flags;          /* Security, priority, compression */
  uint16_t src_node_id;    /* Originating mote ID */
  uint16_t dst_node_id;    /* Next-hop or gateway ID */
  uint32_t seq_num;        /* Monotonic packet sequence counter */
  uint32_t timestamp_s;    /* Epoch timestamp seconds */
  uint32_t timestamp_us;   /* Epoch timestamp microseconds */
} sagitta_header_t;

/* Dynamic Line Rating telemetry payload */
typedef struct __attribute__((packed)) {
  sagitta_header_t header;
  int16_t  conductor_temp_c_q8;  /* Conductor core temp (deg C in Q8.8) */
  int16_t  ambient_temp_c_q8;    /* Ambient air temp (deg C in Q8.8) */
  uint16_t wind_speed_mps_q8;    /* Wind speed (m/s in Q8.8) */
  uint16_t wind_angle_deg_q8;    /* Yaw angle relative to conductor */
  uint16_t solar_flux_w_q8;      /* Solar irradiance (W/m^2 in Q8.8) */
  uint16_t current_ampacity_a;   /* Dynamic allowable ampacity (Amperes) */
  uint16_t measured_current_a;   /* Instantaneous phase current (Amperes) */
  uint8_t  thermal_capacity_pct; /* Used thermal capacity percentage */
  uint8_t  alarm_state;          /* alarm_level_t */
} msg_dlr_state_t;

/* Catenary and ground clearance telemetry payload */
typedef struct __attribute__((packed)) {
  sagitta_header_t header;
  int16_t  tilt_pitch_q8;        /* Longitudinal tilt angle (deg in Q8.8) */
  int16_t  tilt_roll_q8;         /* Transverse swing angle (deg in Q8.8) */
  uint16_t midspan_sag_cm;       /* Estimated mid-span sagitta (cm) */
  uint16_t ground_clearance_cm;  /* Minimum terrain clearance (cm) */
  uint16_t mechanical_tension_n; /* Horizontal tension component (Newtons) */
  uint16_t ice_thickness_mm_q8;  /* Estimated ice thickness (mm in Q8.8) */
  uint8_t  clearance_violation;  /* 1 if clearance breached, else 0 */
  uint8_t  ice_alarm;            /* 1 if ice weight exceeds threshold */
} msg_catenary_state_t;

/* Aeolian vibration alert payload */
typedef struct __attribute__((packed)) {
  sagitta_header_t header;
  uint16_t dominant_freq_hz_q8;  /* Dominant modal frequency (Hz in Q8.8) */
  uint16_t bending_amp_um;       /* Dynamic bending amplitude Yb (micrometers) */
  uint16_t bending_strain_ue;    /* Microstrain at suspension clamp */
  uint16_t vibration_velocity_mm;/* Peak vibration velocity (mm/s) */
  uint32_t fatigue_cycles_accum; /* Cumulative fatigue cycle count */
  uint8_t  galloping_detected;   /* 1 if severe low-frequency galloping */
  uint8_t  severity;             /* alarm_level_t */
} msg_vibration_alert_t;

/* Synchrophasor IEEE C37.118 frame payload */
typedef struct __attribute__((packed)) {
  sagitta_header_t header;
  uint32_t v_mag_rms_mv;         /* Voltage magnitude RMS (millivolts) */
  int32_t  v_phase_rad_q15;      /* Voltage phase angle (radians in Q15) */
  uint32_t i_mag_rms_ma;         /* Current magnitude RMS (milliamperes) */
  int32_t  i_phase_rad_q15;      /* Current phase angle (radians in Q15) */
  uint16_t frequency_mhz;        /* Instantaneous grid frequency (milliHertz) */
  int16_t  rocof_mhz_per_s;      /* Rate of Change of Frequency (mHz/s) */
  uint16_t status_flags;         /* C37.118 status bits */
} msg_synchrophasor_t;

/* Travelling wave fault capture payload */
typedef struct __attribute__((packed)) {
  sagitta_header_t header;
  uint32_t fault_epoch_s;        /* Trigger arrival seconds */
  uint32_t fault_epoch_ns;       /* Trigger arrival nanoseconds */
  uint16_t wavefront_peak_mv;    /* Peak transient voltage surge (mV) */
  uint16_t risetime_ns;          /* Front rise-time (nanoseconds) */
  uint8_t  polarity;             /* 0: negative, 1: positive */
  uint8_t  surge_classification; /* 0: unknown, 1: lightning, 2: fault, 3: switching */
  uint16_t span_identifier;      /* Span segment where wave was latched */
} msg_wavefront_event_t;

#ifdef __cplusplus
}
#endif

#endif /* SAGITTA_MESSAGES_H */
