
module Grid
  use, intrinsic :: iso_c_binding
  implicit none

  private
  interface
    function get_nx() bind(C, name="Grid_get_nx")
      import :: c_ptr
      type(c_ptr) :: get_nx
    end function
    function get_ny() bind(C, name="Grid_get_ny")
      import :: c_ptr
      type(c_ptr) :: get_ny
    end function
    function get_dx() bind(C, name="Grid_get_dx")
      import :: c_ptr
      type(c_ptr) :: get_dx
    end function
    function get_dy() bind(C, name="Grid_get_dy")
      import :: c_ptr
      type(c_ptr) :: get_dy
    end function
    function get_phi() bind(C, name="Grid_get_phi")
      import :: c_ptr
      type(c_ptr) :: get_phi
    end function
    function get_rhs() bind(C, name="Grid_get_rhs")
      import :: c_ptr
      type(c_ptr) :: get_rhs
    end function
  end interface

  public :: nx, ny, dx, dy, phi, rhs, Grid_init, Grid_finalize

  integer(c_int), pointer :: nx,ny
  real(c_double), pointer :: dx,dy
  real(c_double), pointer, dimension(:,:) :: phi=>null(), rhs=>null()

contains
  subroutine Grid_init()
    call c_f_pointer(get_nx(), nx)
    call c_f_pointer(get_ny(), ny)
    call c_f_pointer(get_dx(), dx)
    call c_f_pointer(get_dy(), dy)
    call c_f_pointer(get_phi(), phi, shape=[nx, ny])
    call c_f_pointer(get_rhs(), rhs, shape=[nx, ny])
    print *, "Grid init in Fortran/C++"
  end subroutine

  subroutine Grid_finalize()
    nullify(phi, rhs, nx, ny, dx, dy)
    print *, "Grid finalize in Fortran/C++ interface"
  end subroutine
end module Grid
