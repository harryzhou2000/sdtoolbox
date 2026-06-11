% Shock and Detonation Toolbox Demo Program
% 
% Generate plots and output files for a ZND detonation with the shock front traveling at speed U.
% For exothermic reactions, U > U_CJ
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
clear;clc;
disp('demo_ZNDshk')

P1 = 100000; T1 = 300; U1 = 3000; 
q = 'H2:2 O2:1 N2:3.76';
mech = 'H2O2.yaml';

fig_num = 1;
fname = 'h2air';

gas1 = Solution(mech);
set(gas1, 'T', T1, 'P', P1, 'X', q);

% FIND POST SHOCK STATE FOR GIVEN SPEED
[gas] = PostShock_fr(U1, P1, T1, q, mech);

% SOLVE ZND DETONATION ODES
[out] = zndsolve(gas,gas1,U1,'advanced_output',true);
znd_plot(out,'maxx',1E-4,'xscale','log','species_min',1E-8,'major_species',{'H2', 'O2', 'H2O', 'N2'},'minor_species',{'H', 'O', 'OH','H2O2','HO2'});
znd_fileout(fname,out)

disp(['Reaction zone pulse width (exothermic length) = ',num2str(out.exo_len_ZND)]);
disp(['Reaction zone induction length = ',num2str(out.ind_len_ZND)]);
disp(['Reaction zone pulse time (exothermic time) = ',num2str(out.exo_time_ZND)]);
disp(['Reaction zone induction time = ',num2str(out.ind_time_ZND)]);
