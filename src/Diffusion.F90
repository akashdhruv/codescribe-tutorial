subroutine Diffusion(rhs, phi, dx, dy, Coeff, ix1, ix2, jy1, jy2)

   use iso_c_binding

   implicit none
   !---Argument List -----
   real(c_double), dimension(ix1:ix2, jy1:jy2), intent(inout) :: rhs
   real(c_double), dimension(ix1:ix2, jy1:jy2), intent(in)  :: phi
   real, intent(in) :: Coeff
   real(c_double), intent(in) :: dx, dy
   integer, intent(in) :: ix1, ix2, jy1, jy2

   !---Local Variables
   integer :: i, j

   do j = jy1+1, jy2-1
      do i = ix1+1, ix2-1
         rhs(i, j) = rhs(i, j) &
                        +(Coeff/(dx**2))*(phi(i+1, j)+phi(i-1, j)-2.*phi(i, j)) &
                        +(Coeff/(dy**2))*(phi(i, j+1)+phi(i, j-1)-2.*phi(i, j))
      end do
   end do
   return
end subroutine Diffusion
