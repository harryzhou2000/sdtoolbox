% Shock and Detonation Toolbox Demo Program
% 
% Computes ZND and CV models of detonation with the shock front
% traveling at the CJ speed.  Evaluates various measures of the reaction
% zone thickness and exothermic pulse width, and effective activation energy
%  
% ################################################################################
% Theory, numerical methods and applications are described in the following report:
% 
% SDToolbox:  Numerical Tools for Shock and Detonation Wave Modeling.  
% S. T. Kao, J. L. Zeigler, N. P. Bitter, B. E. Schmidt, J. M. Lawson, and J. E. Shepherd. 
% GALCIT Report FM2018.001.  California Institute of Technology, 2023. 
% https://shepherd.caltech.edu/EDL/PublicResources/sdt/doc/ShockDetonation/ShockDetonation.pdf
% 
% Please cite this report and the website: http://shepherd.caltech.edu/EDL/PublicResources/sdt/ 
% if you use these routines. Refer to LICENCE.txt or the above report for copyright and disclaimers.
% ################################################################################ 
% Updated April 2026
% Requires Cantera 3.0, Downloads and documentation at https://cantera.org/3.0/sphinx/html/matlab/index.html
% Tested with Matlab R2024b and Win11
clear;clc; close all;
disp('demo_ZND_CJ_cell')

P1 = 100000; T1 = 300; 
q = 'H2:2 O2:1 N2:3.76';
mech = 'H2O2.yaml'; 

fname = 'h2air';

[cj_speed, curve, ~, dnew, plot_data] = CJspeed(P1, T1, q, mech);
%CJspeed_plot(2,plot_data,curve,dnew)

gas1 = Solution(mech);
set(gas1, 'T', T1, 'P', P1, 'X', q);

% FIND EQUILIBRIUM POST SHOCK STATE FOR GIVEN SPEED
[gas] = PostShock_eq(cj_speed, P1, T1, q, mech);
u_cj = cj_speed*density(gas1)/density(gas);

% FIND FROZEN POST SHOCK STATE FOR GIVEN SPEED
[gas] = PostShock_fr(cj_speed, P1, T1, q, mech);

% SOLVE ZND DETONATION ODES
[out] = zndsolve(gas,gas1,cj_speed,'advanced_output',true,'t_end',2e-3);

% Find CV parameters including effective activation energy
set(gas,'Temperature',T1,'Pressure',P1,'X',q);
gas = PostShock_fr(cj_speed, P1, T1, q, mech);
Ts = temperature(gas); Ps = pressure(gas);
Ta = Ts*(1.02);
set(gas, 'T', Ta, 'P', Ps, 'X', q);
[CVout1] = cvsolve(gas);
Tb = Ts*(0.98);
set(gas, 'T', Tb, 'P', Ps, 'X', q);
[CVout2] = cvsolve(gas);
% Approximate effective activation energy for CV explosion
taua = CVout1.ind_time;
taub = CVout2.ind_time;
if(taua==0 || taub==0)
    theta_effective_CV = 0;
else
    theta_effective_CV = 1/Ts*((log(taua)-log(taub))/((1/Ta)-(1/Tb)));
end

b = length(out.T);
disp(['ZND computation results; ']);
disp(['Mixture ', q]);
disp(['Mechanism ', mech]);
disp(['Initial temperature ',num2str(T1,'%8.3e'),' K']);
disp(['Initial pressure ',num2str(P1,'%8.3e'),' Pa']);
disp(['CJ speed ',num2str(cj_speed,'%8.3e'),' m/s']);
disp([' ']);
disp(['Reaction zone computation end time = ',num2str(out.tfinal,'%8.3e'),' s']);
disp(['Reaction zone computation end distance = ',num2str(out.xfinal,'%8.3e'),' m']);
disp([' ']);
disp(['T (K), initial = ' num2str(out.T(1),5) ', final ' num2str(out.T(b),5) ', max ' num2str(max(out.T(:)),5)]);
disp(['P (Pa), initial = ' num2str(out.P(1),3) ', final ' num2str(out.P(b),3) ', max ' num2str(max(out.P(:)),3)]);
disp(['M, initial = ' num2str(out.M(1),3) ', final ' num2str(out.M(b),3) ', max ' num2str(max(out.M(:)),3)]);
disp(['u (m/s), initial = ' num2str(out.U(1),5) ', final ' num2str(out.U(b),5) ', cj ' num2str(u_cj,5)]);
disp([' ']);
disp(['Reaction zone thermicity half-width = ',num2str(out.exo_len_ZND,'%8.3e'),' m']);
disp(['Reaction zone maximum thermicity distance = ',num2str(out.ind_len_ZND,'%8.3e'),' m']);
disp(['Reaction zone thermicity half-time = ',num2str(out.exo_time_ZND, '%8.3e'),' s']);
disp(['Reaction zone maximum thermicity time = ',num2str(out.ind_time_ZND,'%8.3e'),' s']);
disp([' ']);
disp(['CV computation results; ']);
disp(['Time to dT/dt_max = ',num2str(CVout1.ind_time, '%8.3e'),' s']);
disp(['Distance to dT/dt_max = ',num2str(CVout1.ind_time*out.U(1), '%8.3e'),' m']);
disp(['Reduced activation energy) = ',num2str(theta_effective_CV,'%8.3e')]);

znd_plot(out,'maxx',1E-3,'major_species',{'H2', 'O2', 'H2O'},...
    'minor_species',{'H', 'O', 'OH', 'H2O2', 'HO2'});

