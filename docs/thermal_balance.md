# Conductor Heat Balance and Dynamic Line Rating (IEEE 738)

## 1. Thermodynamic Equilibrium

The core principle governing overhead conductor temperature is the dynamic thermal balance between heat gain and heat dissipation:

$$q_c + q_r = q_s + q_j$$

where:
* $q_c$: Convective heat loss rate per unit length (W/m)
* $q_r$: Radiated heat loss rate per unit length (W/m)
* $q_s$: Solar heat absorption rate per unit length (W/m)
* $q_j$: Joule (ohmic) heat generation rate per unit length (W/m)

Under non-equilibrium conditions, the conductor temperature $T_c$ evolves according to the first-order differential equation:

$$m \cdot C_p \cdot \frac{dT_c}{dt} = q_j + q_s - q_c - q_r$$

where $m$ is the total mass per unit length (kg/m) and $C_p$ is the specific heat capacity of the conductor alloy (J/(kg * K)).

## 2. Convective Heat Loss ($q_c$)

Convective cooling represents the dominant heat rejection mechanism. Sagitta computes both forced convection ($q_{c1}, q_{c2}$) and natural convection ($q_{cn}$), selecting the maximum value:

$$q_c = \max(q_{c1}, q_{c2}, q_{cn})$$

### 2.1 Forced Convection
For low wind velocities (Reynolds number $N_{Re} \le 2650$):

$$q_{c1} = [1.01 + 0.0372 \cdot (N_{Re})^{0.52}] \cdot k_f \cdot (T_c - T_a) \cdot K_{angle}$$

For high wind velocities ($N_{Re} > 2650$):

$$q_{c2} = [0.0119 \cdot (N_{Re})^{0.6}] \cdot k_f \cdot (T_c - T_a) \cdot K_{angle}$$

The Reynolds number is defined as:

$$N_{Re} = \frac{D \cdot \rho_f \cdot V_w}{\mu_f}$$

where $D$ is conductor outer diameter, $\rho_f$ is air density, $\mu_f$ is dynamic viscosity of air at film temperature $T_f = (T_c + T_a) / 2$, and $V_w$ is wind velocity.

The wind direction correction factor $K_{angle}$ accounts for the yaw angle $\phi$ between the wind vector and the conductor axis:

$$K_{angle} = 1.194 - \cos(\phi) + 0.194 \cdot \cos(2\phi) + 0.368 \cdot \sin(2\phi)$$

### 2.2 Natural Convection
Under calm conditions ($V_w \approx 0$), natural convection prevails:

$$q_{cn} = 0.0205 \cdot \rho_f^{0.5} \cdot D^{0.75} \cdot (T_c - T_a)^{1.25}$$

## 3. Radiated Heat Loss ($q_r$)

Radiation heat rejection is governed by the Stefan-Boltzmann law:

$$q_r = 17.8 \cdot D \cdot \epsilon \cdot \left[ \left(\frac{T_c + 273.15}{100}\right)^4 - \left(\frac{T_a + 273.15}{100}\right)^4 \right]$$

where $\epsilon$ is conductor surface emissivity ($0.5$ for new, up to $0.9$ for weathered lines).

## 4. Solar Heat Absorption ($q_s$)

Solar heat gain is computed from solar irradiance and sun-conductor geometry:

$$q_s = \alpha \cdot Q_{se} \cdot \sin(\theta) \cdot A'$$

where $\alpha$ is solar absorptivity ($0.5$ to $0.9$), $Q_{se}$ is total solar and sky radiated heat flux (W/m^2), $\theta$ is effective angle of incidence, and $A' = D$ is projected area per unit length.

## 5. Joule Heat Generation and Dynamic Ampacity

Resistive heating is given by:

$$q_j = I^2 \cdot R(T_c)$$

where $R(T_c)$ is the temperature-dependent AC resistance:

$$R(T_c) = R(T_0) \cdot [1 + \alpha_{res} \cdot (T_c - T_0)]$$

Inverting the steady-state balance equation yields the maximum allowable continuous current (Dynamic Ampacity $I_{max}$) for a maximum design operating temperature $T_{max}$ (e.g., 75 C or 100 C):

$$I_{max} = \sqrt{\frac{q_c(T_{max}) + q_r(T_{max}) - q_s}{R(T_{max})}}$$
