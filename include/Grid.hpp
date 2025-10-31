
#ifndef GRID_MOD
#define GRID_MOD

#include <FArray.hpp>

namespace Grid {
  extern const int nx, ny;
  extern const double dx, dy;
  extern FArray2D<double> phi, rhs;
}

#endif
