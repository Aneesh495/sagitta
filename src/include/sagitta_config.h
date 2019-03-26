#ifndef SAGITTA_CONFIG_H
#define SAGITTA_CONFIG_H

#ifdef __cplusplus
extern "C" {
#endif

/* System sampling rates and buffer dimensions */
#define VIBRATION_SAMPLE_RATE_HZ     256
#define VIBRATION_FFT_SIZE           256
#define VIBRATION_RING_BUFFER_SIZE   512

#define WAVEFRONT_SAMPLE_RATE_MHZ    10
#define WAVEFRONT_RING_BUFFER_SIZE   1024

#define SYNCHROPHASOR_REPORT_RATE_HZ 60
#define SYNCHROPHASOR_DFT_WINDOW     64

#define TSCH_SLOTFRAME_LENGTH        101
#define TSCH_SLOT_DURATION_US        10000

#define FTSP_SYNC_PERIOD_MS          10000
#define FTSP_TABLE_ENTRIES           8

#define CORRIDOR_MAX_HOPS            64
#define CORRIDOR_MAX_SPAN_MOTES      128

#define IEEE738_DEFAULT_EMISSIVITY   0.80f
#define IEEE738_DEFAULT_ABSORPTIVITY 0.80f
#define STEFAN_BOLTZMANN_CONSTANT    5.670374419e-8f

#define SPEED_OF_LIGHT_AIR_KM_S      294000.0f
#define DEFAULT_SPAN_LENGTH_M        300.0f
#define DEFAULT_STATUTORY_CLEARANCE_M 7.5f

#ifdef __cplusplus
}
#endif

#endif /* SAGITTA_CONFIG_H */
