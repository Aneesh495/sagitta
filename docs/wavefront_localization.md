# Travelling Wave Fault Localization and Transient Analysis

## 1. Principles of High-Voltage Wave Propagation

When an electrical insulation breakdown, lightning strike, or phase-to-ground flashover occurs on an energized overhead line, a step-like electromagnetic disturbance propagates outward in both directions from the fault origin at near the speed of light:

$$v = \frac{1}{\sqrt{L_0 \cdot C_0}} \approx 2.94 \times 10^8\text{ m/s}$$

where $L_0$ and $C_0$ are per-unit-length distributed series inductance and shunt capacitance of the transmission line.

## 2. Double-Ended Travelling Wave Fault Location (TWFL)

Consider a transmission corridor of length $L_{span}$ bounded by Mote A at $x = 0$ and Mote B at $x = L_{span}$. A fault occurs at unknown distance $x_f$ from Mote A.

```
       Mote A                        Fault Origin                    Mote B
       (x = 0)                         (x = x_f)                   (x = L_span)
          |                               |                             |
          |<---------- x_f -------------->|<----- (L_span - x_f) ------>|
          |                               |                             |
          |<==== Wavefront Left (t_A) ====*==== Wavefront Right (t_B) =>|
```

The initial wavefront arrives at Mote A at time $t_A$ and at Mote B at time $t_B$:

$$t_A = t_0 + \frac{x_f}{v}$$
$$t_B = t_0 + \frac{L_{span} - x_f}{v}$$

Subtracting the arrival times eliminates the unknown fault ignition instant $t_0$:

$$t_A - t_B = \frac{2 \cdot x_f - L_{span}}{v}$$

Solving for the fault distance $x_f$ produces the double-ended TWFL equation:

$$x_f = \frac{L_{span} + v \cdot (t_A - t_B)}{2}$$

By maintaining sub-microsecond time synchronization ($|\Delta t_{sync}| < 1\text{ }\mu\text{s}$) across the corridor via Sagitta's network time sync layer, the theoretical spatial location uncertainty is:

$$\delta x = \frac{v \cdot \delta t}{2} \approx \frac{294\text{ m/\mu s} \cdot 0.2\text{ }\mu\text{s}}{2} \approx 29.4\text{ meters}$$

This achieves pinpoint sub-span fault localization, identifying the exact damaged tower span immediately without line patrolling.

## 3. Bewley Lattice Reflection Analysis

At line discontinuities (substation busbars, transformer terminals, line junctions), the characteristic surge impedance changes from $Z_1$ to $Z_2$, creating reflected and transmitted waves governed by reflection coefficient $\Gamma$ and refraction coefficient $T$:

$$\Gamma = \frac{Z_2 - Z_1}{Z_2 + Z_1}, \qquad T = \frac{2 \cdot Z_2}{Z_2 + Z_1}$$

Sagitta's high-speed ring buffer reconstructs the Bewley lattice diagram from successive wave reflections to verify fault type (solid ground vs high-resistance arcing) and discriminate between external lightning impulses and internal phase faults.
