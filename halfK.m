function [phi, w, O, invO_matrix_up, invO_matrix_dn] = halfK(phi, w, O, Proj_k_half, Phi_T, N_up, N_par)
% function [phi, w, O, invO_matrix_up, invO_matrix_dn] = halfK(phi, w, O, Proj_k_half, Phi_T, N_up, N_par)
% Propagate a walker by the kinetic energy propagator exp(-deltau*K/2)
% Inputs:
%   phi: the matrix of a single walker
%   w: the weight of that walker
%   O: the overlap of that walker
%   Proj_k_half: the matrix of the operator exp(-deltau*K/2)
%   Phi_T: the matrix of the trial wave function
%   N_up: the number of spin up electrons
%   N_par: the total number of electrons
% Outputs:
%   phi: the matrix of the propagated single walker
%   w: the weight of the propagated walker
%   O: the overlap of the propagated walker   
%   invO_matrix_up: the inverse of the spin up sector of the walker's overlap matrix 
%   invO_matrix_dn: the inverse of the spin down sector of the walker's overlap matrix 
%
% Huy Nguyen, Hao Shi, Jie Xu and Shiwei Zhang
% ©2014 v1.0
% Package homepage: http://cpmc-lab.wm.edu
% Distributed under the <a href="matlab: web('http://cpc.cs.qub.ac.uk/licence/licence.html')">Computer Physics Communications Non-Profit Use License</a>
% Any publications resulting from either applying or building on the present package 
%   should cite the following journal article (in addition to the relevant literature on the method):
% "CPMC-Lab: A Matlab Package for Constrained Path Monte Carlo Calculations" Comput. Phys. Commun. (2014)

    %% propagate the walker by exp(-deltau*K/2)
    phi=Proj_k_half*phi;

    %% update the inverse of the overlap
    invO_matrix_up=inv(Phi_T(:,1:N_up)'*phi(:,1:N_up));
    invO_matrix_dn=inv(Phi_T(:,N_up+1:N_par)'*phi(:,N_up+1:N_par));
    % calculate the new overlap
    O_new=1/(det(invO_matrix_up)*det(invO_matrix_dn));
    O_ratio=O_new/O;

    %% enforce the constrained path condition
    % If the new weight is negative (O_raio<0), kill the walker by setting its weight to zero
    % real(O_ratio) enforces the phase-free approximation in case of complex phases (because the condition O_ratio>0 only checks the real part of O_ratio)
    if O_ratio>0
        O=O_new;
        w=w*real(O_ratio);
    else
        w=0;
    end

end