% Shock and Detonation Toolbox Demo Program
% 
% Calculates the CJ speed using the Minimum Wave Speed Method and 
% then finds the equilibrium state of the gas behind a shock wave 
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
% Tested with Matlab R2024b and Win 11
%%
clear;clc;
disp('demo_CJstate')
%% set initial state, composition, and gas object
P1 = 100000; T1 = 295; 
q = 'H2:2 O2:1 N2:3.76';    
mech = 'H2O2.yaml';
gas1 = Solution(mech);
set(gas1,'Temperature',T1,'Pressure',P1,'MoleFractions',q);

%% Find CJ speed
[cj_speed] = CJspeed(P1, T1, q, mech);

%% Evaluate gas state
[gas] = PostShock_eq(cj_speed,P1, T1, q, mech);

%% Evaluate properties of gas object 
T2 = temperature(gas);
P2 = pressure(gas);
R2 = density(gas);
V2 = 1/R2;
S2 = entropy_mass(gas);
w2 = density(gas1)*cj_speed/R2;
u2 = cj_speed - w2;
x2 = moleFractions(gas);
c2_eq = soundspeed_eq(gas);
c2_fr = soundspeed_fr(gas);
gamma2_fr =  c2_fr*c2_fr*R2/P2;
gamma2_eq =  c2_eq*c2_eq*R2/P2;

%% Print out
disp(['CJ computation for ',mech,' with composition ',q])
disp(['Initial state P1 = ',num2str(P1),' Pa & T1 = ',num2str(T1),' K']);
disp(['CJ speed ',num2str(cj_speed),' (m/s)']);
disp('CJ State');
disp(['   Pressure ',num2str(P2),' (Pa)']);
disp(['   Temperature ',num2str(T2),' (K)']);
disp(['   Density ',num2str(R2),' (kg/m3)']);
disp(['   Entropy ',num2str(S2),' (J/kg-K)']);
disp(['   w2 (wave frame) ',num2str(w2),' (m/s)']);
disp(['   u2 (lab frame) ',num2str(u2),' (m/s)']);
disp(['   c2 (frozen) ',num2str(c2_fr),' (m/s)']);
disp(['   c2 (equilibrium) ',num2str(c2_eq),' (m/s)']);
disp(['   gamma2 (frozen) ',num2str(gamma2_fr)]);
disp(['   gamma2 (equilibrium) ',num2str(gamma2_eq)]);
