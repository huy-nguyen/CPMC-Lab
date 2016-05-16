% Script to check the validity of all user inputs
%
% Huy Nguyen, Hao Shi, Jie Xu and Shiwei Zhang
% ©2014 v1.0
% Package homepage: http://cpmc-lab.wm.edu
% Distributed under the <a href="matlab: web('http://cpc.cs.qub.ac.uk/licence/licence.html')">Computer Physics Communications Non-Profit Use License</a>
% Any publications resulting from either applying or building on the present package 
%   should cite the following journal article (in addition to the relevant literature on the method):
% "CPMC-Lab: A Matlab Package for Constrained Path Monte Carlo Calculations" Comput. Phys. Commun. (2014)


if mod(Lx,1)~=0||Lx<=0
    display('Error: Lx must be a positive integer!')
    break
elseif mod(Ly,1)~=0||Ly<=0
    display('Error: Ly must be a positive integer!')
    break
elseif mod(Lz,1)~=0||Lz<=0
    display('Error: Lz must be a positive integer!')
    break
elseif mod(N_up,1)~=0||N_up<0
    display('Error: N_up must be a non-negative integer!')
    break
elseif mod(N_dn,1)~=0||N_dn<0
    display('Error: N_dn must be a non-negative integer!')
    break
elseif N_up > 2*( Lx*Ly*Lz)
	display('Error: there are too many spin-up electrons on this lattice')
elseif N_dn > 2*( Lx*Ly*Lz)
	display('Error: there are too many spin-down electrons on this lattice')
elseif kx<=-1||kx>1
    display('Error: kx must be in the interval (-1,1]!')
    break
elseif ky<=-1||ky>1
    display('Error: ky must be in the interval (-1,1]!')
    break
elseif kz<=-1||kz>1
    display('Error: kz must be in the interval (-1,1]!')
    break
elseif U<0
    display('Error: U must be non-negative in the repulsive Hubbard model!')
    break
elseif tx<0
    display('Error: tx must be non-negative!')
    break
elseif ty<0
    display('Error: ty must be non-negative!')
    break
elseif tz<0
    display('Error: tz must be non-negative')
    break
elseif deltau<0
    display('Error: deltau must be positive!')
    break
elseif mod(N_wlk,1)~=0||N_wlk<=0
    display('Error: N_wlk must be a positive integer!')
    break
elseif mod(N_blksteps,1)~=0||N_blksteps<=0
    display('Error: N_blksteps must be a positive integer!')
    break
elseif mod(N_eqblk,1)~=0||N_eqblk<0
    display('Error: N_eqblk must be a non-negative integer!')
    break
elseif mod(N_blk,1)~=0||N_blk<=0
    display('Error: N_blk must be a positive integer!')
    break
elseif mod(itv_modsvd,1)~=0||itv_modsvd<=0
    display('Error: itv_modsvd must be a positive integer!')
    break
elseif mod(itv_pc,1)~=0||itv_pc<=0
    display('Error: itv_pc must be a positive integer!')
    break
elseif mod(itv_Em,1)~=0||itv_Em<=0||itv_Em>N_blksteps
    display('Error: itv_Em must be a positive integer no greater than N_blksteps!')
    break
elseif ~ischar(suffix)
    display ('suffix must be a string!')
    break
else
    if deltau>1
        display('Warning: imaginary time step deltau>1 is too large!!!')
        display('Ctrl+c to stop running!')
    end
    if N_wlk*N_blksteps*(N_eqblk+N_blk)*Lx*Ly*(N_up+N_dn)>1e11
        display('Warning: N_wlk*N_blksteps*(N_eqblk+N_blk)*Lx*Ly*(N_up+N_dn) > 1e11')
        display('This computation might take more than a day!')
        display('Ctrl+c to stop running!')
    end
    if itv_modsvd>N_blksteps
        display('Warning: itv_modsvd is greater than N_blksteps. The walkers will not be periodically re-orthogonalized.')
        display('Ctrl+c to stop running!')
    end
    if itv_pc>N_blksteps
        display('itv_pc is greater than N_blksteps. There will be no population control.')
        display('Ctrl+c to stop running!')
    end
end
