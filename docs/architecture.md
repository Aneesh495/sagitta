# Sagitta System Architecture

## Overview

Sagitta is an embedded cyber-physical engine written in nesC for autonomous high-voltage overhead transmission line monitoring motes. Suspended directly on energized phase conductors (69 kV to 765 kV) and energized through inductive current transformer harvesting, each Sagitta mote continuously estimates conductor physical state, computes real-time dynamic line rating (DLR), tracks aeolian vibration fatigue, detects high-frequency travelling wave fault transients, and telemeters state vectors along linear transmission corridors.

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
|              IEC 60870-5-104 / DNP3 Telemetry Protocol Server               |
+=============================================================================+
```

## Hardware Abstraction and Execution Model

The system executes on low-power 16-bit and 32-bit microcontrollers (e.g., MSP430, ARM Cortex-M) coupled with an IEEE 802.15.4 transceiver and specialized analog front-ends:
1. Split-core current transformer for non-invasive power harvesting and phase current measurement.
2. Ultra-low-noise triaxial MEMS accelerometer sampled up to 256 Hz for vibration spectral analysis and static tilt angle measurement.
3. Conductor core and surface contact thermistors, combined with an ambient air temperature and crosswind sensor array.
4. High-speed comparator and ADC trigger circuit capable of sub-microsecond edge latching for high-voltage travelling waves.
5. Dual-cell supercapacitor buffer for uninterrupted operation during low line-current intervals.

The software architecture strictly adheres to the nesC component-based execution model:
* Components communicate exclusively through typed interfaces providing commands and handling split-phase events.
* Synchronous code runs in non-preemptive run-to-completion tasks.
* Real-time hardware deadlines (sampling, timer ticks, radio frame delimiters) are serviced via asynchronous events (`async event`) protected by atomic execution blocks (`atomic { ... }`).
