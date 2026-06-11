% Shock and Detonation Toolbox Demo Program
% 
% Generate plots and output files for a ZND detonation with the shock front
% traveling at the CJ speed.
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
%%
clear;clc;close all;
disp('demo_ZNDCJ')
file_name = 'CH4_air';
P1 = 20E3; T1 = 295; 
q = 'CH4:1 O2:2 N2:1.25';
mech = 'gri30_highT.yaml';
[cj_speed, curve, ~, dnew, plot_data] = CJspeed(P1, T1, q, mech);
%CJspeed_plot(2,plot_data,curve,dnew)

gas1 = Solution(mech);
set(gas1, 'T', T1, 'P', P1, 'X', q);
U_s = 1.005*cj_speed;  % necessary start slightly overdriven not to get stuck at sonic point
% FIND POST SHOCK STATE FOR GIVEN SPEED
[gas] = PostShock_fr(U_s, P1, T1, q, mech);

% SOLVE ZND DETONATION ODES
[out] = zndsolve(gas,gas1,U_s,'advanced_output',true,'t_end',5E-5);
znd_plot(out,'xscale','log','xunit','mm','xmult',1E3,'species_min',1E-8,'maxx',10,'major_species',{'CH4', 'O2', 'H2O', 'CO2'},...
    'minor_species',{'H', 'O', 'OH', 'CH2O','CO', 'H2'},'species_plt','mole','prnfig',false);
znd_fileout(file_name,out)
disp(['Mech ',mech]);
disp(['mix ',q])
disp(['CJ speed = ',num2str(cj_speed),' m/s']);
disp(['Reaction zone pulse width (exothermic length) = ',num2str(out.exo_len_ZND),' m']);
disp(['Reaction zone induction length = ',num2str(out.ind_len_ZND),' m']);
disp(['Reaction zone pulse time (exothermic time) = ',num2str(out.exo_time_ZND),' s']);
disp(['Reaction zone induction time = ',num2str(out.ind_time_ZND),' s']);
