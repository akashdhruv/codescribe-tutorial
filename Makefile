# -----------------------------------------------------------------------------
# Makefile for MPI-based PDE Solver (C++ + Fortran .F90)
# -----------------------------------------------------------------------------
# Usage:
#   make            - build the solver
#   make run NP=4   - run with 4 MPI ranks
#   make clean      - remove build artifacts
# -----------------------------------------------------------------------------

CXX       := g++
FC        := gfortran

TARGET    := pdesolver
SRC_DIR   := src
OBJ_DIR   := build

CXXFLAGS  := -O2 -std=c++17 -Wall -Wextra -Iinclude -Isrc
FFLAGS    := -O2 -J$(OBJ_DIR)
LDFLAGS   := -lgfortran -lm

CPP_SOURCES := $(SRC_DIR)/Grid.cpp $(SRC_DIR)/main.cpp

F90_SOURCES := $(SRC_DIR)/Grid_fi.F90 \
               $(SRC_DIR)/Initialize.F90 \
               $(SRC_DIR)/Diffusion.F90 \
               $(SRC_DIR)/Solver.F90 \

CPP_OBJECTS := $(patsubst $(SRC_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(CPP_SOURCES))
F90_OBJECTS := $(patsubst $(SRC_DIR)/%.F90,$(OBJ_DIR)/%.o,$(F90_SOURCES))

OBJECTS := $(CPP_OBJECTS) $(F90_OBJECTS)

all: $(TARGET)

$(OBJ_DIR):
	@mkdir -p $(OBJ_DIR)

# --- Compile C++ sources ------------------------------------------------------
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp | $(OBJ_DIR)
	@echo "Compiling C++ $<"
	$(CXX) $(CXXFLAGS) -c $< -o $@

# --- Compile Fortran .F90 sources --------------------------------------------
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.F90 | $(OBJ_DIR)
	@echo "Compiling Fortran $<"
	$(FC) $(FFLAGS) -c $< -o $@

# --- Link everything together -------------------------------------------------
$(TARGET): $(OBJECTS)
	@echo "Linking $(TARGET)"
	$(CXX) $(OBJECTS) -o $@ $(LDFLAGS)

# --- Run helper ---------------------------------------------------------------
run: $(TARGET)
	@if [ -z "$(NP)" ]; then \
		echo "Usage: make run NP=<num_processes>"; \
	else \
		mpirun -np $(NP) ./$(TARGET); \
	fi

# --- Utility targets ----------------------------------------------------------
print-objects:
	@echo "OBJECTS=$(OBJECTS)"

clean:
	rm -rf $(OBJ_DIR) $(TARGET) *.mod

.PHONY: all run clean print-objects
