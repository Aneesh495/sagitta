# Catenary Sagitta Mechanics and Ground Clearance

## 1. Catenary Formulation

An overhead conductor suspended between two level support structures separated by span length $L$ hangs under self-weight according to the hyperbolic catenary curve:

$$y(x) = \frac{H}{w} \cdot \left[ \cosh\left(\frac{w \cdot x}{H}\right) - 1 \right]$$

where:
* $H$: Horizontal component of conductor tension (N)
* $w$: Linear weight density of the conductor including ice accretion (N/m)
* $x$: Horizontal coordinate measured from the midpoint of the span ($-L/2 \le x \le L/2$)

For transmission spans with low sag-to-span ratios ($s/L < 0.1$), the Taylor series expansion truncates to the parabolic approximation:

$$y(x) \approx \frac{w \cdot x^2}{2 \cdot H}$$

The maximum mid-span sag, known geometrically as the *sagitta* ($s$), occurs at $x = L/2$:

$$s = \frac{w \cdot L^2}{8 \cdot H}$$

## 2. Tilt Angle to Sagitta Transfer Function

Sagitta motes equipped with triaxial MEMS accelerometers measure local inclination angle $\theta_{tilt}$ relative to gravity at mounting position $x_m$ near the suspension clamp:

$$\tan(\theta_{tilt}) = \left. \frac{dy}{dx} \right|_{x = x_m} = \sinh\left(\frac{w \cdot x_m}{H}\right) \approx \frac{w \cdot x_m}{H}$$

Substituting $H = w \cdot x_m / \tan(\theta_{tilt})$ into the sagitta formula produces the direct inclination-to-sag transfer function:

$$s = \frac{L^2}{8 \cdot x_m} \cdot \tan(\theta_{tilt})$$

Because $L$ and $x_m$ are fixed installation constants, the mid-span sagitta is directly proportional to the tangent of the measured conductor inclination angle at the support pylon.

## 3. Conductor State Change Equation

Conductor tension varies dynamically with temperature and environmental loading according to the classical cubic state change equation:

$$H_2^2 \cdot \left[ H_2 + E \cdot A \cdot \left( \frac{w_1^2 \cdot L^2}{24 \cdot H_1^2} + \alpha_{exp} \cdot (T_2 - T_1) - \frac{H_1}{E \cdot A} \right) \right] = \frac{E \cdot A \cdot w_2^2 \cdot L^2}{24}$$

where:
* $E$: Modulus of elasticity of the composite conductor (Pa)
* $A$: Total cross-sectional area (m^2)
* $\alpha_{exp}$: Thermal coefficient of linear expansion (1/K)
* $H_1, T_1, w_1$: Initial tension, temperature, and linear weight
* $H_2, T_2, w_2$: Final tension, temperature, and linear weight under current ambient conditions

## 4. Ice Accretion Detection

When atmospheric icing occurs, radial ice thickness $r_{ice}$ increases the total linear weight:

$$w_{total} = w_{bare} + \pi \cdot \rho_{ice} \cdot g \cdot (D \cdot r_{ice} + r_{ice}^2)$$

By continuously comparing the observed mechanical tension $H_{obs}$ against the expected bare-wire tension $H_{bare}(T_c)$ derived from the thermal model, Sagitta isolates the excess mechanical weight increment:

$$\Delta w = w_{total} - w_{bare}$$

This enables real-time estimation of radial glaze/rime ice accretion thickness:

$$r_{ice} = \sqrt{\left(\frac{D}{2}\right)^2 + \frac{\Delta w}{\pi \cdot \rho_{ice} \cdot g}} - \frac{D}{2}$$

## 5. Dynamic Ground Clearance Monitoring

Given a survey terrain elevation profile $z_{terrain}(x)$ beneath the span, the instantaneous minimum vertical ground clearance $C_{min}$ is monitored in real time:

$$C_{min} = \min_{x} \left( z_{support} - y(x) - z_{terrain}(x) \right)$$

When $C_{min}$ drops below regulatory statutory safety margins (e.g., 7.5 m for 230 kV lines), an automated priority alarm is dispatched to the substation gateway.
