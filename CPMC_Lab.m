function [E_ave,E_err,savedFileName]=CPMC_Lab(Lx,Ly,Lz,N_up,N_dn,kx,ky,kz,U,tx,ty,tz,deltau,N_wlk,N_blksteps,N_eqblk,N_blk,itv_modsvd,itv_pc,itv_Em,suffix)
% function [E_ave,E_err,savedFileName]=CPMC_Lab(Lx,Ly,Lz,N_up,N_dn,kx,ky,kz,U,tx,ty,tz,deltau,N_wlk,N_blksteps,N_eqblk,N_blk,itv_modsvd,itv_pc,itv_Em, suffix)
% Perform a constrained path Monte Carlo calculatiion. Main function in the CPMC-Lab package
% Input
%   Lx: The number of lattice sites in the x direction.
%   Ly: The number of lattice sites in the y direction.
%   Lz: The number of lattice sites in the z direction.
%   N_up: The number of spin-up electrons
%   N_dn: The number of spin-down electrons
%   kx: The x component of the twist angle in TABC (twist-averaging boundary condition)
%   ky: The y component of the twist angle in TABC
%   kz: The z component of the twist angle in TABC
%   U: The on-site repulsion strength in the Hubbard Hamiltonian
%   tx: The hopping amplitude between nearest-neighbor sites in the x direction
%   ty: The hopping amplitude between nearest neighbor sites in the y direction
%   tz: The hopping amplitude between nearest neighbor sites in the z direction
%   deltau: The imaginary time step
%   N_wlk: The number of random walkers
%   N_blksteps: The number of random walk steps in each block
%   N_eqblk: The number of blocks used to equilibrate the random walk before energy measurement takes place
%   N_blk: The number of blocks used in the measurement phase
%   itv_modsvd: The interval between two adjacent modified Gram-Schmidt re-orthonormalization of the random walkers.
%   itv_pc: The interval between two adjacent population controls
%   itv_Em: The interval between two adjacent energy measurements
%   suffix: an identifying string e.g. timestamp to be appended to the end of the saved *.mat file
% Output:
%   E_ave: the ground state energy
%   E_err: the standard error in the ground state energy
%   savedFileName: name of the saved data file
%
% Huy Nguyen, Hao Shi, Jie Xu and Shiwei Zhang
% ©2014 v1.0
% Package homepage: http://cpmc-lab.wm.edu
% Distributed under the <a href="matlab: web('http://cpc.cs.qub.ac.uk/licence/licence.html')">Computer Physics Communications Non-Profit Use License</a>
% Any publications resulting from either applying or building on the present package 
%   should cite the following journal article (in addition to the relevant literature on the method):
% "CPMC-Lab: A Matlab Package for Constrained Path Monte Carlo Calculations" Comput. Phys. Commun. (2014)

%% Initialization
tic; % start the  timer
initialization; % initialize internal constants, form the trial wave function and assemble the initial population of walkers
format long;
flag_mea=0; %determine when a measurement should take place
E=0;
W=0;

% Preallocate arrays:
E_blk=zeros(N_blk,1); % array to store the energy measured in every block
W_blk=zeros(N_blk,1); % array to store the total weight in every block

%% Equilibration phase
for i_blk=1:N_eqblk
    for j_step=1:N_blksteps
        [Phi, w, O, E, W] = stepwlk(Phi, N_wlk, N_sites, w, O, E, W, H_k, Proj_k_half, flag_mea, Phi_T, N_up, N_par, U, fac_norm, aux_fld);
        if mod(j_step,itv_modsvd)==0
            [Phi, O] = stblz(Phi, N_wlk, O, N_up, N_par); % re-orthonormalize the walkers
        end
        if mod(j_step,itv_pc)==0
            [Phi, w, O]=pop_cntrl(Phi, w, O, N_wlk, N_sites, N_par); % population control
        end
    end
end

%% Measurement phase    
for i_blk=1:N_blk
    for j_step=1:N_blksteps
        if mod(j_step,itv_Em)==0
            flag_mea=1;
        else
            flag_mea=0;
        end
        % propagate the walkers:
        [Phi, w, O, E_blk(i_blk), W_blk(i_blk)] = stepwlk(Phi, N_wlk, N_sites, w, O, E_blk(i_blk), W_blk(i_blk), H_k, Proj_k_half, flag_mea, Phi_T, N_up, N_par, U, fac_norm, aux_fld);
        if mod(j_step,itv_modsvd)==0
            [Phi, O] = stblz(Phi, N_wlk, O, N_up, N_par); % re-orthonormalize the walkers
        end
        if mod(j_step,itv_pc)==0
            [Phi, w, O]=pop_cntrl(Phi, w, O, N_wlk, N_sites, N_par); % population control
        end
        if mod(j_step, itv_Em)==0
            % update the exponent of the pre-factor exp(-deltau*(H-E_T))
            fac_norm=(real(E_blk(i_blk)/W_blk(i_blk))-0.5*U*N_par)*deltau;
        end
    end
    E_blk(i_blk)=E_blk(i_blk)/W_blk(i_blk);
    display(strcat('E(',int2str(i_blk),')=',num2str(real(E_blk(i_blk)))))
end

%% Results
E=real(E_blk);
E_ave=mean(E)
E_err=std(E)/sqrt(N_blk)
% The total computational time:
time=toc() % stops the timer

%% Save data to a *.mat file
save (savedFileName, 'E', 'E_ave', 'E_err', 'time');
save (savedFileName, '-append', 'Lx', 'Ly','Lz', 'N_up', 'N_dn', 'kx', 'ky','kz', 'U', 'tx', 'ty','tz');
save (savedFileName, '-append', 'deltau', 'N_wlk', 'N_blksteps', 'N_eqblk', 'N_blk', 'itv_pc','itv_modsvd','itv_Em');
save (savedFileName, '-append', 'H_k', 'E_nonint_v', 'Phi_T');

%% Explanation of saved quantities:
% E: the array of energy of each block
% time: The total computational time
% E_nonint_v: the non-interacting energy levels of the system
% Phi_T: the trial wave function
% For other saved quantities, type "help CPMC_Lab"

end