subroutine Initialize()
   use Grid
   implicit none
   integer :: i, j

   call Grid_init()

   do j = 1, ny
      do i = 1, nx
         phi(i, j) = sin(2.0*3.14159*i/nx)*sin(2.0*3.14159*j/ny)
         rhs(i, j) = 0.0
      end do
   end do

   print *, "Fortran initializer: Grid initialized."
end subroutine Initialize
