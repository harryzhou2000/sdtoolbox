% Shock and Detonation Toolbox Demo Program
% 
% Explosion computation simulating constant temperature and pressure reaction.
% Reguires function tpsys.m for ode solver
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
clear; clc; close all;
disp('Constant Temperature and Pressure Reactor')
%% initial gas state
P1 = oneatm; T1 = 3000;
mech = 'Mevel2015.yaml';
gas  = Solution(mech);
q = 'H2:10 O2:1';    
set(gas,'Temperature',T1,'Pressure',P1,'MoleFractions',q);
%% set up for integration routine
mw = molecularWeights(gas);
nsp = nSpecies(gas);
y0 = [massFractions(gas)];
t_end = 1e-5;
tel = [0 t_end];
options = odeset('RelTol',1.e-5,'AbsTol',1.e-12,'Stats','off');
% out.x = time, out.y = species profiles
out = ode15s(@tpsys,tel,y0,options,gas,mw,T1,P1);
%% Plotting species
figure('Name', 'TP Reactor')
maxx = max(out.x);
minx = min(out.x);
fontsize=12;
set(gca,'FontSize',fontsize,'LineWidth',2,...
    'linestyleorder',{'-','-.','--',':'},'nextplot','add');
plot(out.x(:),out.y(:,:));
xlabel('Time (s)','FontSize',fontsize);
ylabel('species mass fraction','FontSize',fontsize);
title('TP Reactor','FontSize',fontsize);
xlim([minx maxx]);
legend(speciesName(gas,1:nsp),'Location','eastoutside');

