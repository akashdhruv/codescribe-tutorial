subroutine Solver()
   use Grid
   implicit none

   integer :: iteration
   real(kind=8) :: error

   real(kind=8), dimension(20), parameter :: center_vals = (/ &
                                             0.0000000000000000d0, &
                                             -71.322917938232422d0, &
                                             -142.64583587646484d0, &
                                             -213.96875381469727d0, &
                                             -285.29167175292969d0, &
                                             -356.61458969116211d0, &
                                             -427.93750762939453d0, &
                                             -499.26042556762695d0, &
                                             -570.58334350585938d0, &
                                             -641.90626144409180d0, &
                                             -713.22917938232422d0, &
                                             -784.55209732055664d0, &
                                             -855.87501525878906d0, &
                                             -927.19793319702148d0, &
                                             -998.52085113525391d0, &
                                             -1069.8437690734863d0, &
                                             -1141.1666870117188d0, &
                                             -1212.4896049499512d0, &
                                             -1283.8125228881836d0, &
                                             -1355.1354408264160d0 &
                                             /)

   print *, "Fortran Solver: Starting diffusion solve"
   do iteration = 1, 20
      error = rhs(10, 10)-center_vals(iteration)
      print *, "Error with Reference: Iteration", iteration, ":", error
      call Diffusion(rhs, phi, dx, dy, 1.0d0, 1, nx, 1, ny)
   end do
   print *, "Fortran Solver: Completed"
end subroutine Solver
