
#include <Grid.hpp>

namespace Grid {
  const int nx = 50;
  const int ny = 50;
  const double dx = 1.0 / static_cast<double>(nx);
  const double dy = 1.0 / static_cast<double>(ny);
  FArray2D<double> phi(nx, ny);
  FArray2D<double> rhs(nx, ny);
}

extern "C" {
  const int* Grid_get_nx() { return &Grid::nx; }
  const int* Grid_get_ny() { return &Grid::ny; }
  const double* Grid_get_dx() { return &Grid::dx; }
  const double* Grid_get_dy() { return &Grid::dy; }
  double* Grid_get_phi() { return Grid::phi.data; }
  double* Grid_get_rhs() { return Grid::rhs.data; }
}
