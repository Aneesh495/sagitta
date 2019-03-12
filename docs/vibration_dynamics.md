# Aeolian Vibration and Conductor Fatigue Dynamics

## 1. Karman Vortex Shedding and Excitation

When laminar crosswinds impinge upon a cylindrical high-voltage conductor, alternating vortices detach from the top and bottom surfaces in the wake region. This Karman vortex street generates periodic oscillating lift forces perpendicular to the wind vector.

The vortex shedding frequency $f_s$ is governed by the Strouhal relationship:

$$f_s = \frac{S_t \cdot V_w}{D}$$

where:
* $S_t$: Strouhal number (typically $0.185$ to $0.20$ for stranded overhead conductors)
* $V_w$: Wind component perpendicular to the line (m/s)
* $D$: Conductor outer diameter (m)

For wind velocities between $0.5\text{ m/s}$ and $7.0\text{ m/s}$, vortex shedding excites standing natural acoustic waves on the conductor in the frequency range of $5\text{ Hz}$ to $100\text{ Hz}$.

## 2. Fixed-Point Embedded Spectral Analysis

To identify active vibrational modes without floating-point coprocessors, Sagitta acquires $N = 256$ acceleration samples at $F_s = 256\text{ Hz}$ and applies an in-place Radix-2 decimation-in-time Fast Fourier Transform (FFT) utilizing Q15/Q31 fixed-point trigonometric twiddle factor tables:

$$X[k] = \sum_{n=0}^{N-1} x[n] \cdot w[n] \cdot e^{-j \frac{2\pi}{N} k n}$$

where $w[n]$ is a 16-bit Hann window applied prior to transformation to eliminate spectral leakage.

The power spectral density $S[k] = |X[k]|^2$ is evaluated to detect resonance peaks exceeding baseline thresholds, yielding dominant frequency $f_{peak}$ and peak spectral power $P_{peak}$.

## 3. Poffenberger-Swart Dynamic Bending Amplitude

Dynamic strain at the suspension clamp is the primary cause of fatigue failure in overhead transmission conductors. The standard Poffenberger-Swart formula maps measured peak-to-peak displacement $Y_b$ at distance $x_b = 89\text{ mm}$ ($3.5\text{ inches}$) from the clamp to total dynamic bending strain $\epsilon_b$:

$$\epsilon_b = \frac{D \cdot p^2}{4 \cdot (e^{-p \cdot x_b} - 1 + p \cdot x_b)} \cdot Y_b$$

where the conductor stiffness parameter $p$ is defined as:

$$p = \sqrt{\frac{H}{E \cdot I}}$$

with $H$ representing conductor tension, $E$ composite elastic modulus, and $I$ cross-sectional moment of inertia.

## 4. Palmgren-Miner Cumulative Fatigue Life

Cyclic fatigue damage accumulation is evaluated using the Palmgren-Miner linear damage hypothesis:

$$D_{fatigue} = \sum_{i=1}^{M} \frac{n_i}{N_i}$$

where $n_i$ is the number of stress cycles experienced at stress range $\Delta \sigma_i = E \cdot \epsilon_{b,i}$, and $N_i$ is the allowable fatigue endurance cycles derived from the EPRI / CIGRE safe-border Woehler S-N curve:

$$N_i = C_{w} \cdot (\Delta \sigma_i)^{-m_w}$$

with material constant $C_w$ and fatigue exponent $m_w \approx 4.5$ for aluminum conductor steel reinforced (ACSR) strands.

When cumulative damage $D_{fatigue}$ approaches critical thresholds ($D \ge 0.8$), Sagitta generates an inspection ticket identifying clamp strand fatigue risk.
