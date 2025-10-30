subroutine Diffusion(rhs, phi, dx, dy, Coeff, ix1, ix2, jy1, jy2)

   implicit none
   !---Argument List -----
   real, dimension(:, :, :), intent(inout) :: rhs
   real, dimension(:, :, :), intent(in)  :: phi
   real, intent(in) :: Coeff
   real, intent(in) :: dx, dy
   integer, intent(in) :: ix1, ix2, jy1, jy2

   !---Local Variables
   integer :: i, j, k

   k = 1
   do j = jy1, jy2
      do i = ix1, ix2
         rhs(i, j, k) = rhs(i, j, k) &
                        +(Coeff/(dx**2))*(phi(i+1, j, k)+phi(i-1, j, k)-2.*phi(i, j, k)) &
                        +(Coeff/(dy**2))*(phi(i, j+1, k)+phi(i, j-1, k)-2.*phi(i, j, k))
      end do
   end do
   return
end subroutine Diffusion
