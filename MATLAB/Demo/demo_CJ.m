% Shock and Detonation Toolbox Demo Program
% 
% Calculate detonation Chapman-Jouguet (CJ) speed based on the
% initial gas state.  Uses the minimum wave speed method and the SDToolbox
% function 'CJspeed' from the 'postshock' module.
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
disp('demo_CJ')
%%
% Initial state specification:
%  P1 = Initial Pressure  
%  T1 = Initial Temperature 
%  q = Initial Composition 
%  mech = Cantera mechanism File name
P1 = 100000; T1 = 300;
q = 'H2:2 O2:1 N2:3.76';
mech = 'H2O2.yaml';
% fig_num  = 1 to get diagnostic plots for minimum wave speed calculation
%          = 0 for no plots
fig_num = 1;
gas = Solution(mech);
set(gas,'Temperature',T1,'Pressure',P1,'MoleFractions',q);
% Compute CJ speed 
[cj_speed, curve, fit_goodness, dratio_cj, plot_data] = CJspeed(P1, T1, q, mech);
%% Outputs:
% cj_speed - detonation speed 
% The following outputs are optional, omit these variables if unneeded.
% curve - matlab cfit object containing parameters of quadratic fit for
% wave speed as a function of density
curve
% fit_goodness - matlab object with fitting statistics
fit_goodness
% dratio_cj - density ratio at CJ point
disp(['CJ computation for ',mech,' with composition ',q])
disp(['CJ speed ',num2str(cj_speed),' (m/s)',' Density ratio ',num2str(dratio_cj)]);
disp(['Use demo_CJstate to find thermodynamic properties at CJ point']);

%% Plots:
CJspeed_plot(fig_num,plot_data,curve,dratio_cj)


