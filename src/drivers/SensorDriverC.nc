#include "sagitta_types.h"

/**
 * SensorDriverC wires the physical hardware sensor drivers:
 * ADXL355 MEMS accelerometer, BME280 weather station, PT100 RTD thermistor,
 * and Rogowski current transducer.
 */
configuration SensorDriverC {
  provides {
    interface InertialSensor as Adxl355;
    interface WeatherStation as Bme280;
    interface SensorAdc as Pt100Rtd;
    interface CurrentTransducer as RogowskiCoil;
  }
}
implementation {
  components Adxl355DriverP;
  components Bme280DriverP;
  components Pt100DriverP;
  components RogowskiDriverP;

  Adxl355 = Adxl355DriverP.Adxl355;
  Bme280 = Bme280DriverP.Bme280;
  Pt100Rtd = Pt100DriverP.Pt100Rtd;
  RogowskiCoil = RogowskiDriverP.RogowskiCoil;
}
