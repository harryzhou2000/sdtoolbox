% Shock and Detonation Toolbox Demo Program
% 
% Generates plots and output files for a constant volume
% explosion simulation where the initial conditions are shocked reactants
% behind a shock traveling at a user defined shock speed U1. The time
% dependence of species, pressure, and temperature are computed using the
% user supplied reaction mechanism file.
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
% Tested with Matlab R2024b and Win 11
%%
clear;clc;
disp('demo_cvshk')

P1 = 100000; T1 = 300; U1 = 2000; 
q = 'H2:2 O2:1 N2:3.76';
mech = 'H2O2.yaml';
file_name = 'h2air';
fig_num = 1;


% SET UP GAS OBJECT
gas1 = Solution(mech);
set(gas1, 'T', T1, 'P', P1, 'X', q);

% FIND POST SHOCK STATE FOR GIVEN SPEED
[gas] = PostShock_fr(U1, P1, T1, q, mech);

% SOLVE CONSTANT VOLUME EXPLOSION ODES, MAKE CV PLOTS
[CVout] = cvsolve(gas);
cv_plot(CVout);

disp(['Reaction zone pulse time (exothermic time) = ',num2str(CVout.exo_time)]);
disp(['Reaction zone induction time = ',num2str(CVout.ind_time)]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE OUTPUT TEXT FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = [file_name, '_', num2str(U1), '.txt'];
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

fprintf(fid, '# SHOCK SPEED (M/S) %5.2f\n\n', U1);

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

