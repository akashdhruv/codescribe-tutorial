subroutine Finalize()
   use Grid
   call Grid_finalize()
   print *, "Fortran finalizer: Grid finalized."
end subroutine Finalize
