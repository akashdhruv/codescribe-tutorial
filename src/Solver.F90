subroutine Solver()
   use Grid
   implicit none

   integer :: iteration

   print *, "Fortran Solver: Starting diffusion solve"
   do iteration = 1, 20
      print *, "Fortran Solver: Iteration-", iteration,", Center-",rhs(10,10)
      call Diffusion(rhs, phi, dx, dy, 1.0, 1, nx, 1, ny)
   end do
   print *, "Fortran Solver: Completed"
end subroutine Solver
