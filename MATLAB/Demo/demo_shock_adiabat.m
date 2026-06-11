% Shock and Detonation Toolbox Demo Program
% 
% Generates the points on a frozen shock adiabat and creates an output file.
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
disp('demo_shock_adiabat')
% set initial state of gas, avoid using precise stoichiometric ratios. 
P1 = 100000; T1 = 300; 
q = 'O2:0.2095 N2:0.7808 CO2:0.0004 Ar:0.0093';    
mech = 'airNASA9ions.yaml';   
gas1 = Solution(mech);
set(gas1,'Temperature',T1,'Pressure',P1,'MoleFractions',q);
disp(['Computing frozen postshock state for ',q,' using ',mech]);
Umin = soundspeed_fr(gas1) + 50;
%
% Evaluate the frozen state of the gas behind a shock wave traveling at a
% speeds up to a maximum value. 
%
i = 1;
for speeds = (Umin:100:2000)
speed(i) = speeds;
[gas] = PostShock_fr(speed(i),P1, T1, q, mech);
P(i) = pressure(gas);
R(i) = density(gas);
T(i) = temperature(gas);
a(i) = soundspeed_fr(gas);
gamma(i) = a(i)*a(i)*R(i)/P(i);
w2(i) = density(gas1)*speed(i)/R(i);
u2(i) = speed(i) - w2(i);
i=i+1;
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create output file in text format with Tecplot-style variable labels for
% columns
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = ['shock_adiabat.txt'];
d = date;
fid = fopen(fn, 'w');
fprintf(fid, '# Shock adiabat\n');
fprintf(fid, '# Calculation run on %s\n', d );
fprintf(fid, '# Initial conditions\n');
fprintf(fid, '# Temperature (K) %4.1f\n', T1);
fprintf(fid, '# Pressure (Pa) %2.1f\n', P1);
fprintf(fid, '# Density (kg/m^3) %1.4e\n', density(gas1));
fprintf(fid, ['# Initial species mole fractions: ' q '\n']);
fprintf(fid, ['# Reaction mechanism: ' mech '\n\n']);
fprintf(fid, 'Variables = "shock speed (m/s)", "density (kg/m3)", "Temperature (K)", "Pressure (atm)", "sound speed - fr (m/s)", "particle speed (m/s)", "shock-fixed speed (m/s)", "gamma (fr)"\n');
z = [speed; R; T; P; a; u2; w2; gamma];
fprintf(fid, '%14.5e \t %14.5e \t %14.5e \t %14.5e \t %14.5e \t %14.5e \t %14.5e \t %14.5e\n', z);
fclose(fid);
