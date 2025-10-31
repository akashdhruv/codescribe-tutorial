
subroutine Initialize()
  use, intrinsic :: iso_c_binding
  use Grid

  implicit none

  interface
    subroutine Initialize_wrapper() bind(C, name="Initialize_wrapper")
    end subroutine Initialize_wrapper
  end interface

  call Initialize_wrapper()
end subroutine Initialize
