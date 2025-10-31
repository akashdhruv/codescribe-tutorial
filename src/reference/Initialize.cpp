
#include <Initialize.hpp>

void Initialize() {
  using namespace Grid;

  for (int j = 1; j <= ny; ++j) {
    for (int i = 1; i <= nx; ++i) {
      phi(i, j) = std::sin(2.0 * 3.14159 * i / nx) * std::sin(2.0 * 3.14159 * j / ny);
      rhs(i, j) = 0.0;
    }
  }

  std::cout << "C++ initializer: Grid initialized." << std::endl;

  return;
}

extern "C" {
  void Initialize_wrapper() {
    Initialize();
  }
}
