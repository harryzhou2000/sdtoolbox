% Shock and Detonation Toolbox Demo Program
%
% Generates plots and output files for a adiabatic 
% explosion simulation with constant pressure.
% The time dependence of species, pressure, and
% temperature are computed using the user supplied reaction mechanism file.
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
clear;clc;close all;
plots = true;
disp('demo_cp')
q = 'CH4:1 O2:2 N2:7.52';
mechanism = 'gri30_highT';

mech = [mechanism '.yaml'];
P0 = 3.11E6; T0 = 1525;
gas = Solution(mech);
set(gas, 'T', T0, 'P', P0, 'X', q);
rho1 = density(gas);
P1 = pressure(gas);
T1 = temperature(gas);
disp(['CP explosion computation']);
disp(['Mechanism: ',mech]);
disp(['Initial State:']);
disp(['   Composition: ',q]);
disp(['   Pressure ',num2str(P1),' (Pa)']);
disp(['   Temperature ',num2str(T1),' (K)']);
disp(['   Density ',num2str(rho1),' (kg/m3)']);
tfinal = 1E-4;    % need to set final time sufficiently long for low temperature cases
[CPout] = cpsolve(gas,'t_end',tfinal,'abs_tol',1E-12,'rel_tol',1E-12);
t_ind = CPout.ind_time;   % induction time
t_pulse = CPout.exo_time; % pulse width
disp(['   Induction time = ',num2str(t_ind),' (s)']);
disp(['   Pulse time  = ',num2str(t_pulse),' (s)']);
%%
% Plotting
if (plots)
yes = true(1);
cp_plot(CPout,'maxt',tfinal,'P_scale',0,'P_unit','P (MPa)','t_scale',1E-3,'t_unit','t (ms)','major_species',{'CH4','CO2', 'CO','H2', 'O2', 'H2O'},...
    'minor_species',{'H', 'O', 'OH', 'CH2','CH3','H2O', 'H2O2', 'HO2'},'species_plt','mole','prnfig',yes);
end



