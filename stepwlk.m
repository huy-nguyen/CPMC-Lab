function [phi, w, O, E, W] = stepwlk(phi, N_wlk, N_sites, w, O, E, W, H_k, Proj_k_half, flag_mea, Phi_T, N_up, N_par, U, fac_norm, aux_fld)
% function [phi, w, O, E, W] = stepwlk(phi, N_wlk, N_sites, w, O, E, W, H_k, Proj_k_half, flag_mea, Phi_T, N_up, N_par, U, fac_norm, aux_fld)
% Perform one step of the random walk
% Inputs:
%   phi: the whole ensemble of walkers
%   N_wlk: the number of walkers
%   N_sites: the total number of lattice sites
%   w: the array of weights of all the walkers
%   O: the array of overlaps of all the walkers
%   E: the total energy of all walkers
%   W: the total weight of all walkers
%   H_k: the one-body kinetic Hamiltonian
%   Proj_k_half: the matrix of the operator exp(-deltau*K/2)
%   flag_mea: the flag (1 or 0) that specifies whether the energy should the measured in this step
%   Phi_T: the matrix of the trial wave function
%   N_up: the number of spin up electrons
%   N_par: the total number of electrons
%   U: the on-site repulsion strength in the Hubbard model
%   fac_norm: the exponent of the pre-factor exp(-deltau*(H-E_T))
%   aux_fld: the 2x2 matrix containing all the possible values of the quantity exp(gamma*s(sigma)*x_i) (used in V.m only)
% Outputs:
%   phi: the ensemble of walkers after propagation
%   w: the new array of weights of all walkers
%   O: the new array of overlaps of all walkers
%   E: the new total energy of all walkers
%   W: the new total weight of all walkers
%   
% Huy Nguyen, Hao Shi, Jie Xu and Shiwei Zhang
% ©2014 v1.0
% Package homepage: http://cpmc-lab.wm.edu
% Distributed under the <a href="matlab: web('http://cpc.cs.qub.ac.uk/licence/licence.html')">Computer Physics Communications Non-Profit Use License</a>
% Any publications resulting from either applying or building on the present package 
%   should cite the following journal article (in addition to the relevant literature on the method):
% "CPMC-Lab: A Matlab Package for Constrained Path Monte Carlo Calculations" Comput. Phys. Commun. (2014)

%% Propagate each walker:
e=zeros(N_wlk,1); % Array containing the energy of each walker
for i_wlk=1:N_wlk
    Phi=phi(:,:,i_wlk);
    if w(i_wlk)>0
         % multiply by the pre-factor exp(-deltau*(E_T)) in the ground-state projector 
         % and by the prefactor exp(-0.5*U*(N_up+N_dn)) in the Hirsch transformation
        w(i_wlk)=w(i_wlk)*exp(fac_norm);
        % propagate by the kinetic term exp(-1/2*deltau*K)
        [Phi, w(i_wlk), O(i_wlk), invO_matrix_up, invO_matrix_dn]=halfK(Phi, w(i_wlk), O(i_wlk), Proj_k_half, Phi_T, N_up, N_par);
        if w(i_wlk)>0
            % propagate each lattice site of a walker by the potential term:
            for j_site=1:N_sites
                if w(i_wlk)>0
                    [Phi(j_site,:), O(i_wlk), w(i_wlk), invO_matrix_up, invO_matrix_dn]=V(Phi(j_site,:), Phi_T(j_site,:), N_up, N_par, O(i_wlk), w(i_wlk), invO_matrix_up, invO_matrix_dn, aux_fld);
                end
            end
        end
        if w(i_wlk)>0
            % propagate by the kinetic term exp(-1/2*deltau*K)
            [Phi(:,:), w(i_wlk), O(i_wlk), invO_matrix_up, invO_matrix_dn]=halfK(Phi(:,:), w(i_wlk), O(i_wlk), Proj_k_half, Phi_T, N_up, N_par);            
            if w(i_wlk)>0
                % measure the energy if needed:
                if flag_mea==1
                    e(i_wlk)=measure(H_k, Phi(:,:), Phi_T,  invO_matrix_up, invO_matrix_dn, N_up, N_par, U);
                end
            end
        end
    end
    phi(:,:,i_wlk)=Phi;
end

%% Compute the ensemble's total energy and weight if measurement took place
if flag_mea==1
    for i_wlk=1:N_wlk
        if w(i_wlk)>0
            E=E+e(i_wlk)*w(i_wlk);
            W=W+w(i_wlk);
        end
    end
end
end