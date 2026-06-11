% Shock and Detonation Toolbox Demo Program
% 
% Generates plots and output files for a constant volume
% explosion simulation where the initial conditions are shocked reactants
% using shock speed given by CJ detonation simulation. The time dependence
% of species, pressure, and temperature are computed using the user
% supplied reaction mechanism file.
%  
% ################################################################################
% Theory, numerical methods and applications are described in the following report:
% 
% SDToolbox:  Numerical Tools for Shock and Detonation Wave Modeling.  
% S. T. Kao, J. L. Zeigler, N. P. Bitter, B. E. Schmidt, J. M. Lawson, and J. E. Shepherd. 
% GALCIT Report FM2018.001.  California Institute of Technology, 2023. 
% 
% Please cite this report and the website: http://shepherd.caltech.edu/EDL/PublicResources/sdt/ 
% if you use these routines. Refer to LICENCE.txt or the above report for copyright and disclaimers.
% ################################################################################ 
% Updated April 2026
% Requires Cantera 3.0, Downloads and documentation at https://cantera.org/3.0/sphinx/html/matlab/index.html
% Tested with Matlab R2024b and Win11
%%
clear;clc;
disp('demo_cvCJ')
%% User specified input
P1 = 100000; T1 = 300; 
%q = 'CH4:1 O2:2 N2:7.52';
q = 'C3H8:0.55 O2:5 N2:18.8';
mech = 'gri30_highT.yaml';
file_name = 'ch4air';

fig_num1 = 1; % figure number for temperature profile
fig_num2 = 2; % for CJspeed plots
file_name = 'hc-air';
%% 
% FIND CJ SPEED AND RELATED DATA, MAKE CJ PLOTS
% [cj_speed, curve, goodness, dnew, plot_data] = CJspeed(P1, T1, q, mech);
% CJspeed_plot(fig_num2,plot_data,curve,dnew)
[cj_speed] = CJspeed(P1, T1, q, mech);

% SET UP GAS OBJECT
gas1 = Solution(mech);
set(gas1, 'T', T1, 'P', P1, 'X', q);

% FIND POST SHOCK STATE FOR GIVEN SPEED
[gas] = PostShock_fr(cj_speed, P1, T1, q, mech);

% SOLVE CONSTANT VOLUME EXPLOSION ODES, MAKE CV PLOTS
[CVout] = cvsolve(gas,'t_end',1e-2,'rel_tol',1e-5,'abs_tol',1e-7);
cv_plot(CVout,'t_scale',1);

disp(['Reaction zone pulse time (exothermic time) = ',num2str(CVout.exo_time)]);
disp(['Reaction zone induction time = ',num2str(CVout.ind_time)]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE OUTPUT TEXT FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = [file_name, '_', num2str(cj_speed), '.txt'];
d = date;
P = P1/oneatm;

fid = fopen(fn, 'w');
fprintf(fid, '# CV: EXPLOSION STRUCTURE CALCULATION\n');
fprintf(fid, '# CALCULATION RUN ON %s\n\n', d);

fprintf(fid, '# INITIAL CONDITIONS\n');
fprintf(fid, '# TEMPERATURE (K) %4.1f\n', T1);
fprintf(fid, '# PRESSURE (ATM) %2.1f\n', P);
fprintf(fid, '# DENSITY (KG/M^3) %1.4e\n', density(gas1));
fprintf(fid, ['# SPECIES MOLE FRACTIONS: ' q '\n']);

fprintf(fid, '# SHOCK SPEED (M/S) %5.2f\n\n', cj_speed);

fprintf(fid, '# Induction Times\n');
fprintf(fid, '# Time to Peak DTDt =   %1.4e\n', CVout.ind_time);
fprintf(fid, '# Time to 0.1 Peak DTDt =   %1.4e\n', CVout.ind_time_10);
fprintf(fid, '# Time to 0.9 Peak DTDt =   %1.4e\n\n', CVout.ind_time_90);

fprintf(fid, '# REACTION ZONE STRUCTURE\n\n');

fprintf(fid, '# THE OUTPUT DATA COLUMNS ARE:\n');
fprintf(fid, 'Variables = Time(s), Temperature(K), Pressure(atm)\n');

y = [CVout.time; CVout.T; CVout.P];
fprintf(fid, '%1.4g \t %5.1f \t %3.2f\n', y);

fclose(fid);

