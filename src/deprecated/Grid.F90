module Grid

   use iso_c_binding

   implicit none

   integer(c_int), parameter :: nx = 50, ny = 50
   real(c_double), parameter :: dx = 1.0/real(nx), dy = 1.0/real(ny)
   real(c_double), dimension(nx, ny), save :: phi, rhs

contains
  subroutine Grid_init()
    print *, "Grid init in Fortran"
  end subroutine

  subroutine Grid_finalize()
    print *, "Grid finalize in Fortran"
  end subroutine

end module Grid
