# Sagitta

Autonomous High-Voltage Dynamic Line Rating (DLR), Conductor Catenary State Estimation, Aeolian Vibration Spectral Analyzer, and Travelling-Wave Fault Localization Engine in nesC.

```
+=============================================================================+
|                           HIGH-VOLTAGE CONDUCTOR                            |
|             (Phase A / Phase B / Phase C: 69 kV - 765 kV ACSR/ACSS)         |
+=============================================================================+
        |                                                           |
   [Inductive CT]                                          [Triaxial MEMS]
   Harvest Coil                                            Tilt / Vibration
        |                                                           |
        v                                                           v
+------------------+   +-------------------+   +--------------------+
|  Power Manager   |   |   Thermal Model   |   | Catenary Estimator |
|  Induction/Solar |   |  IEEE 738 Balance |   |  Sagitta & Clear.  |
|  Supercapacitor  |   |  Dynamic Ampacity |   |  Ice Load Tracker  |
+------------------+   +-------------------+   +--------------------+
        |                        |                       |
        +------------------------+-----------------------+
                                 |
                                 v
+-----------------------------------------------------------------------------+
|                          SAGITTA CORE nesC RUNTIME                          |
|                                                                             |
|  +--------------------+   +--------------------+   +---------------------+  |
|  | Vibration Analyzer |   | Synchrophasor PMU  |   | Travelling Wave     |  |
|  | 256-pt Radix-2 FFT |   | C37.118 Phasor/DF  |   | Sub-us TWFL Solver  |  |
|  | Fatigue Life Model |   | Frequency & ROCOF  |   | Bewley Lattice      |  |
|  +--------------------+   +--------------------+   +---------------------+  |
|                                                                             |
|  +--------------------+   +--------------------+   +---------------------+  |
|  | Protective Relays  |   | Fixed-Point Math   |   | Sensor HAL Drivers  |  |
|  | ANSI 50/51/21/87   |   | CORDIC / Kalman 3D |   | ADXL355, BME280,    |  |
|  | ANSI 27/59/67/25   |   | Daubechies D4 DWT  |   | PT100, Rogowski     |  |
|  +--------------------+   +--------------------+   +---------------------+  |
|                                                                             |
|  +-----------------------------------------------------------------------+  |
|  |                        CORRIDOR NETWORK STACK                         |  |
|  |  * Linear TSCH (Time-Slotted Channel Hopping MAC)                     |  |
|  |  * FTSP (Corridor-Compensated Sub-Microsecond Clock Sync)             |  |
|  |  * L-CTP (Linear Collection Tree Routing with In-Network Aggregation) |  |
|  |  * AES-128-CCM* (Authenticated Encryption & Replay Defense)           |  |
|  +-----------------------------------------------------------------------+  |
+-----------------------------------------------------------------------------+
                                 |
                         [802.15.4 Radio]
                                 |
                                 v
+=============================================================================+
|                      TRANSMISSION CORRIDOR HOP-BY-HOP                       |
|   Tower (k-1) <---------> Tower (k) <---------> Tower (k+1) ...             |
+=============================================================================+
                                 |
                                 v
+=============================================================================+
|                      SUBSTATION CONCENTRATOR GATEWAY                        |
|   * IEC 60870-5-104 Server    * DNP3 Outstation    * IEC 61850 GOOSE/SV     |
+=============================================================================+
```

## System Overview

Sagitta is an embedded cyber-physical software platform written in nesC for autonomous overhead high-voltage transmission line monitoring motes. Clamped directly to energized conductors (69 kV to 765 kV) and self-powered by inductive current-transformer harvesting, Sagitta motes perform real-time continuous dynamic line rating, conductor state estimation, and electrical grid protection at the physical transmission edge:

1. **IEEE 738 Heat Balance and Dynamic Ampacity**: Continuous solution of the non-linear heat balance differential equation ($q_c + q_r = q_s + q_j$), calculating real-time dynamic ampacity and 15-minute emergency overload duration.
2. **Catenary Sagitta and Clearance Mechanics**: Exact hyperbolic and parabolic catenary state estimation mapping accelerometer inclination angle to mid-span sagitta ($s = \frac{w L^2}{8 H}$) and terrain ground clearance.
3. **Aeolian Vibration and Cumulative Fatigue**: In-place Radix-2 fixed-point FFT spectral analysis on embedded MCUs, automated Karman vortex shedding frequency extraction ($f_s = \frac{S_t V}{D}$), Poffenberger-Swart clamp bending strain, and Palmgren-Miner cumulative fatigue life tracking.
4. **Travelling Wave Fault Localization (TWFL)**: Sub-microsecond wavefront capture ($v \approx 294,000\text{ km/s}$) and double-ended time-difference-of-arrival (TDOA) fault distance solver achieving sub-span precision ($< 30\text{ meters}$).
5. **Synchrophasor Estimation (IEEE C37.118)**: Recursive sliding-window Discrete Fourier Transform (RDFT) phasor estimation, phase-locked loop frequency tracking, and finite-difference Rate of Change of Frequency (ROCOF) monitoring.
6. **Substation Telemetry Gateway & Fieldbus Protocols**: Substation integration via DNP3 (IEEE 1815) Outstation, IEC 60870-5-104 Server, IEC 61850 GOOSE, and Sampled Values 9-2LE.
7. **Linear Corridor TSCH Mesh and FTSP**: Specialized linear topology Time-Slotted Channel Hopping MAC, Flooding Time Synchronization Protocol maintaining $< 2\text{ }\mu\text{s}$ corridor alignment, and AES-128-CCM* cryptographic message authentication.
8. **Deterministic Simulation & Verification Engine**: Standalone C11 discrete-event transmission corridor simulator (`sagitta_sim`) and test runner (`sagitta_test`) compiling cleanly with Clang/GCC on macOS and Linux with zero external dependencies.

---

## Architectural Subsystems

### 1. Thermal Subsystem (IEEE 738)
* `ConvectiveCoolingP.nc`: Forced and natural convective heat dissipation under variable wind yaw angles using Morgan and Churchill-Bernstein formulations.
* `RadiativeCoolingP.nc`: Stefan-Boltzmann radiation cooling to ambient surroundings.
* `SolarAbsorptionP.nc`: Effective solar radiation absorption based on sun-conductor geometry.
* `JouleHeatingP.nc`: Temperature-dependent AC skin-effect resistance and ohmic loss.
* `TransientThermalP.nc`: 4th-order Runge-Kutta transient thermal ODE integrator.
* `HeatBalanceP.nc`: Newton-Raphson steady-state equilibrium temperature solver.
* `DynamicLineRatingP.nc`: DLR orchestrator, dynamic ampacity calculation, and thermal alarm dispatch.

### 2. Catenary Mechanics & Ground Clearance
* `CatenarySagP.nc`: Parabolic and hyperbolic catenary geometry evaluator.
* `TiltToSagP.nc`: Low-pass filtered MEMS inclination-to-sagitta transfer function.
* `IceAccretionP.nc`: Atmospheric glaze/rime ice thickness detector tracking mechanical weight increments.
* `TensionTrackerP.nc`: Conductor cubic state change equation solver across thermal/mechanical loading.
* `GroundClearanceP.nc`: Digital terrain profile clearance comparator and statutory alarm generator.

### 3. Vibration & Fatigue Dynamics
* `FastFourierTransformP.nc`: In-place Radix-2 fixed-point Q15 Decimation-In-Time FFT with 16-bit Hann window.
* `ModalBendingP.nc`: Poffenberger-Swart dynamic bending amplitude and clamp microstrain calculation.
* `GallopingDetectorP.nc`: 0.1 Hz to 2.0 Hz low-frequency high-amplitude subconductor galloping detector.
* `FatigueLifeP.nc`: Palmgren-Miner cumulative cycle damage tracker using EPRI Woehler S-N curves.
* `VibrationAnalysisP.nc`: Vibration sample buffer manager, spectral scheduler, and alert dispatcher.

### 4. Travelling Wave Fault Location (TWFL)
* `WavefrontCaptureP.nc`: Circular DMA ring buffer and sub-microsecond comparator trigger latch.
* `DoubleEndedTwflP.nc`: TDOA fault distance solver: $x_f = \frac{L + v (t_A - t_B)}{2}$.
* `BewleyLatticeP.nc`: Successive wave reflection lattice diagram reconstructor.
* `SurgeClassifierP.nc`: Rise-time and tail-time transient wave classifier (lightning vs flashover vs switching).
* `TravellingWaveP.nc`: Travelling wave coordinator and over-the-air fault reporter.

### 5. Mathematical Library & Signal Processing
* `CordicEngineP.nc`: 16-iteration CORDIC fixed-point rotation, vectoring, and square root engine.
* `ButterworthFilterP.nc`: 2nd-order Direct Form II Transposed IIR low-pass filter.
* `ChebyshevFilterP.nc`: 2nd-order Chebyshev Type I band-pass filter for aeolian modal bands.
* `MovingAverageFilterP.nc`: O(1) circular window boxcar average filter.
* `MedianFilterP.nc`: 5-point running median filter for impulse spike rejection.
* `KalmanFilter3DP.nc`: 3-state linear Kalman filter tracking inclination, angular rate, and sag.
* `Daubechies4P.nc`: 4-tap Daubechies D4 discrete wavelet transform for singularity extraction.

### 6. Protective Relaying Suite
* `InstantaneousOvercurrent50P.nc`: ANSI 50 sub-cycle instantaneous overcurrent protection.
* `TimeOvercurrent51P.nc`: ANSI 51 inverse-time overcurrent protection with IEEE very inverse curves.
* `DistanceRelay21P.nc`: ANSI 21 mho and quadrilateral distance protection (Zone 1 and Zone 2).
* `UnderVoltage27P.nc`: ANSI 27 undervoltage protection with definite time delay.
* `OverVoltage59P.nc`: ANSI 59 overvoltage protection.
* `DirectionalRelay67P.nc`: ANSI 67 directional phase fault protection.
* `DifferentialRelay87P.nc`: ANSI 87 line current differential protection.
* `SynchroCheck25P.nc`: ANSI 25 synchronism-check reclosing supervision.

### 7. Substation Fieldbus Protocols
* `Iec61850GooseP.nc`: Fast Ethernet protection frames (EtherType 0x88B8).
* `Iec61850SvP.nc`: Sampled Values 9-2LE synchro-sampling publisher (EtherType 0x88BA).
* `C37118FramerP.nc`: IEEE C37.118-2011 binary synchrophasor data frame builder.
* `Dnp3OutstationP.nc`: DNP3 (IEEE 1815) Object Group 30 analog and Group 1 binary encoder.
* `ModbusRtuP.nc`: Modbus RTU serial holding register formatter with CRC-16.

### 8. Sensor HAL Drivers
* `Adxl355DriverP.nc`: Low-noise 20-bit triaxial seismic/vibration MEMS accelerometer driver.
* `Bme280DriverP.nc`: Barometric pressure, humidity, and atmospheric density transducer driver.
* `Pt100DriverP.nc`: 4-wire RTD platinum thermistor bridge with Callendar-Van Dusen linearization.
* `RogowskiDriverP.nc`: High-speed current transducer driver for di/dt surge capture.

---

## Directory Structure

```
sagitta/
├── LICENSE
├── Makefile
├── CMakeLists.txt
├── README.md
├── docs/
│   ├── architecture.md
│   ├── thermal_balance.md
│   ├── catenary_mechanics.md
│   ├── vibration_dynamics.md
│   ├── wavefront_localization.md
│   └── mesh_protocol.md
├── src/
│   ├── include/
│   │   ├── sagitta_types.h
│   │   ├── sagitta_config.h
│   │   ├── sagitta_messages.h
│   │   ├── conductor_params.h
│   │   ├── catenary_params.h
│   │   ├── vibration_params.h
│   │   ├── phasor_params.h
│   │   ├── wavefront_params.h
│   │   └── power_params.h
│   ├── interfaces/
│   ├── thermal/
│   ├── mechanics/
│   ├── vibration/
│   ├── synchrophasor/
│   ├── transient/
│   ├── power/
│   ├── network/
│   ├── hal/
│   ├── math/
│   ├── protection/
│   ├── conductors/
│   ├── protocols/
│   ├── drivers/
│   └── app/
├── sim/
│   ├── engine/
│   ├── scada/
│   └── main_sim.c
├── tests/
│   ├── unit/
│   ├── integration/
│   └── test_runner.c
└── tools/
    ├── corridor_visualizer.py
    ├── generate_epri_profiles.py
    ├── nesc_syntax_validator.py
    └── verify_style.py
```

---

## Quickstart and Verification

### Prerequisites
* Clang or GCC supporting C11 (`-std=c11`).
* Make or CMake.
* Python 3.8+ (standard library only, zero pip dependencies).

### Building
```bash
# Build both simulator and test binaries
make all
```

### Running the Test Suite
```bash
# Execute unit and integration tests (42 assertions across 21 test suites)
make test
```

### Running the Transmission Corridor Simulator
```bash
# Launch interactive ANSI dashboard simulation
make sim

# Custom simulation parameters: 20 discrete steps, 850 A current, fault at 1850 m
./bin/sagitta_sim --steps 20 --current 850 --fault 1850
```

### Running the Syntax and Style Validators
```bash
# Verify nesC component structure and zero-em-dash invariant
make lint
```

### Visualizing Catenary Profiles
```bash
# Generate terminal ASCII profile of transmission corridor
python3 tools/corridor_visualizer.py 4
```

---

## License

MIT License. See [LICENSE](LICENSE) for full details.
