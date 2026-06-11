% Shock and Detonation Toolbox Demo Program
% 
% Calculates post-relected-shock state for a specified shock speed and a specified 
% initial mixture.  In this demo, both shocks are reactive, i.e. the computed states 
% behind both the incident and reflected shocks are EQUILIBRIUM states.  
% The reflected state is computed by the SDToolbox function reflected_eq.
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
clear; clc;
disp('demo_reflected_eq')
%% Set initial state
P1 = 100000; T1 = 300;
q = 'H2:2 O2:1 N2:3.76';    
mech = 'H2O2.yaml';
gas1 = Solution(mech);
set(gas1, 'T', T1, 'P', P1, 'X', q); 
gas2 = Solution(mech);
gas3 = Solution(mech);
%% compute minimum incident equilibrium shock speed
[cj_speed,R2] = CJspeed(P1, T1, q, mech);   
% UI must be greater than or equal to cj_speed
% UI is speed in lab frame relative to reflecting surface
UI = 1.2*cj_speed;
%% compute incident wave postshock state
[gas2] = PostShock_eq(UI, P1, T1, q, mech);
% Output - gas2 is postshock Cantera gas object
disp(['Incident shock speed ',num2str(UI),' (m/s)']);
disp('Initial Conditions');
disp(['   Pressure ',num2str(P1/oneatm),' (atm)']);
disp(['   Temperature ',num2str(T1),' (K)']);
%% compute reflected shock post-shock state
disp(['Computing equilibrium post-reflected-shock state for ',q,' using ',mech]);
[p3,UR,gas3] = reflected_eq(gas1,gas2,gas3,UI);
% Output
% UR - reflected shock wave speed relative to reflecting surface
% p3 - pressure behind reflected shock wave
% gas3 - Cantera gas object for equilibrium state behind reflectes shock wave
disp(['Reflected Shock Speed UR = ', num2str(UR), ' (m/s)']);
disp('Post-reflected-shock state');
disp(['   Pressure ',num2str(p3),' (Pa)']);
disp(['   Temperature ',num2str(temperature(gas3)),' (K)']);
disp(['Incident gas state'])
gas1()
disp(['Post-incident-shock gas state'])
gas2()
disp(['Post-reflected-shock gas state'])
gas3()
