CC ?= clang
CFLAGS ?= -Wall -Wextra -O2 -std=c11 -pedantic
INCLUDES = -Isrc/include -Isim/engine -Isim/scada

SIM_SRC = sim/engine/corridor_model.c \
          sim/engine/weather_generator.c \
          sim/engine/sagitta_sim.c \
          sim/scada/dnp3_gateway.c \
          sim/main_sim.c

TEST_SRC = tests/test_runner.c \
           tests/unit/test_thermal.c \
           tests/unit/test_catenary.c \
           tests/unit/test_vibration.c \
           tests/unit/test_wavefront.c \
           tests/unit/test_crypto.c \
           tests/unit/test_power.c \
           tests/integration/test_corridor_pipeline.c \
           sim/engine/corridor_model.c \
           sim/engine/weather_generator.c \
           sim/engine/sagitta_sim.c \
           sim/scada/dnp3_gateway.c

BIN_DIR = bin

.PHONY: all clean test sim lint format check-style

all: $(BIN_DIR)/sagitta_sim $(BIN_DIR)/sagitta_test

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(BIN_DIR)/sagitta_sim: $(SIM_SRC) | $(BIN_DIR)
	$(CC) $(CFLAGS) $(INCLUDES) $(SIM_SRC) -lm -o $@

$(BIN_DIR)/sagitta_test: $(TEST_SRC) | $(BIN_DIR)
	$(CC) $(CFLAGS) $(INCLUDES) $(TEST_SRC) -lm -o $@

test: $(BIN_DIR)/sagitta_test
	./$(BIN_DIR)/sagitta_test

sim: $(BIN_DIR)/sagitta_sim
	./$(BIN_DIR)/sagitta_sim --steps 5

lint: check-style
	python3 tools/nesc_syntax_validator.py

check-style:
	python3 tools/verify_style.py

clean:
	rm -rf $(BIN_DIR)
