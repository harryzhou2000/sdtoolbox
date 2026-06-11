% Shock and Detonation Toolbox Demo Program
% 
% Calculate the EQUILIBRIUM post shock state based on the initial gas
% state and the shock speed.  Evaluates the shock jump conditions using a fixed
% composition using SDToolbox function PostShock_eq.
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
disp('demo_PSeq')
%% Initial state specification:
%  P1 = Initial Pressure  
%  T1 = Initial Temperature 
%  U = Shock Speed 
%  q = Initial Composition 
%  mech = Cantera mechanism File name
P1 = 100000; T1 = 300; U = 2000;
q = 'H2:2 O2:1 N2:3.76';    
mech = 'H2O2.yaml'; 
%% Compute equilibrium postshock state
[gas] = PostShock_eq(U, P1, T1, q, mech);
% Output 
% gas - Cantera gas object for postshock state
P1atm = P1/oneatm;
Ps = pressure(gas);
Psatm = Ps/oneatm;
Ts = temperature(gas);
disp(['Initial state: ',q, ', P1 = ',num2str(P1atm),' atm, T1 = ',num2str(T1),' K'])
disp(['Mechanism: ', mech])
disp(['Equilibrium postshock state: Ps = ',num2str(Psatm),' atm, Ts = ', num2str(Ts),' K'])

