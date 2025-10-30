module Grid

   implicit none

   integer, parameter :: nx = 50, ny = 50
   real, parameter :: dx = 1/nx, dy = 1/ny
   real, dimension(nx, ny) :: phi, rhs

end module Grid
