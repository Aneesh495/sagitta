cmake_minimum_required(VERSION 3.12)
project(sagitta C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -O2 -pedantic")

include_directories(src/include sim/engine sim/scada)

set(SIM_SOURCES
  sim/engine/corridor_model.c
  sim/engine/weather_generator.c
  sim/engine/sagitta_sim.c
  sim/scada/dnp3_gateway.c
  sim/main_sim.c
)

set(TEST_SOURCES
  tests/test_runner.c
  tests/unit/test_thermal.c
  tests/unit/test_catenary.c
  tests/unit/test_vibration.c
  tests/unit/test_wavefront.c
  tests/unit/test_crypto.c
  tests/unit/test_power.c
  tests/integration/test_corridor_pipeline.c
  sim/engine/corridor_model.c
  sim/engine/weather_generator.c
  sim/engine/sagitta_sim.c
  sim/scada/dnp3_gateway.c
)

add_executable(sagitta_sim ${SIM_SOURCES})
target_link_libraries(sagitta_sim m)

add_executable(sagitta_test ${TEST_SOURCES})
target_link_libraries(sagitta_test m)

enable_testing()
add_test(NAME CorridorTestSuite COMMAND sagitta_test)
