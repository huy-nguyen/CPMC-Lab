% Script to initialize internal quantities
%
% Huy Nguyen, Hao Shi, Jie Xu and Shiwei Zhang
% ©2014 v1.0
% Package homepage: http://cpmc-lab.wm.edu
% Distributed under the <a href="matlab: web('http://cpc.cs.qub.ac.uk/licence/licence.html')">Computer Physics Communications Non-Profit Use License</a>
% Any publications resulting from either applying or building on the present package 
%   should cite the following journal article (in addition to the relevant literature on the method):
% "CPMC-Lab: A Matlab Package for Constrained Path Monte Carlo Calculations" Comput. Phys. Commun. (2014)

%% Check the validity of user inputs
validation;

%% Initialize internal quantities
N_sites=Lx*Ly*Lz;
N_par=N_up+N_dn;
% form the one-body kinetic Hamiltonian
H_k=H_K(Lx, Ly,Lz, kx, ky,kz, tx, ty,tz);
% the matrix of the operator exp(-deltau*K/2)
Proj_k_half = expm(-0.5*deltau*H_k); 

%% Initialize the trial wave function and calculate the ensemble's initial energy 
% Diagonalize the one-body kinetic Hamiltonian to get the non-interacting single-particle orbitals:
[psi_nonint,E_nonint_m] = eig(H_k);
E_nonint_v=diag(E_nonint_m);
% assemble the non-interacting single-particle orbitals into a Slater determinant:
Phi_T=horzcat(psi_nonint(:,1:N_up),psi_nonint(:,1:N_dn));
% the kinetic energy of the trial wave function
E_K=sum(E_nonint_v(1:N_up))+sum(E_nonint_v(1:N_dn));
% the potential energy of the trial wave function
n_r_up=diag(Phi_T(:,1:N_up)*(Phi_T(:,1:N_up))');
n_r_dn=diag(Phi_T(:,N_up+1:N_par)*(Phi_T(:,N_up+1:N_par))');
E_V=U*n_r_up'*n_r_dn;
% the total energy of the trial wave function = the initial trial energy
E_T = E_K+E_V;

%% Assemble the initial population of walkers
Phi=zeros(N_sites,N_par,N_wlk);
% initiate each walker to be the trial wave function
for i=1:N_wlk
    % Phi(:,:,i) is the ith walker. Each is a matrix of size N_sites by N_par
    % The left N_sites by N_up block is the spin up sector
    % The rest is the spin down sector
    % They are propagated independently and only share the auxiliary field
    Phi(:,:,i)=Phi_T; 
end;
% initiate the weight and overlap of each walker to 1
w=ones(N_wlk,1);
O=ones(N_wlk,1);
% the arrays that store the energy and weight at each block
E_blk=zeros(N_blk,1);
W_blk=zeros(N_blk,1);

%% initialize auxiliary filed constants
% exponent of the prefactor exp(-deltau*(-E_T)) in the ground state projector 
% fac_norm also include -0.5*U*(N_up+N_dn), the exponent of the prefactor in the Hirsch transformation
fac_norm=(real(E_T)-0.5*U*N_par)*deltau; 
%gamma in Hirsch's transformation
gamma=acosh(exp(0.5*deltau*U)); 
% aux_fld is the 2x2 matrix containing all the possible values of the quantity exp(-gamma*s(sigma)*x_i)
aux_fld=zeros(2,2); 
% The first index corresponds to spin up or down
% The second index corresponds to the auxiliary field x_i=1 or x_i=-1
for i=1:2
    for j=1:2
        aux_fld(i,j)=exp(gamma*(-1)^(i+j));
    end;
end;

%% filename to be saved
savedFileName=strcat(int2str(Lx),'x',int2str(Ly),'x',int2str(Lz),'_',int2str(N_up),'u',int2str(N_dn),'d_U',num2str(U, '%4.2f'),'_kx',num2str(kx,'%+7.4f'),'_ky',num2str(ky,'%+7.4f'),'_kz',num2str(kz,'%+7.4f'),'_Nwlk_',int2str(N_wlk),suffix,'.mat');

%% randomize the random number generator seed based on the current time
rand('twister',sum(100*clock));