% Shock and Detonation Toolbox Demo Program
% 
% Equilibrium computation at over a range of temperatures and pressures
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

clear; clc; close all;
disp('Constant Temperature and Pressure Equilibrium')
%% initial gas state
P1 = oneatm; T1 = 300;
mech = 'airNASA9ions.yaml';
gas  = Solution(mech);
q = 'N2:0.7809 O2:0.2095  Ar:0.0093  CO2:0.0004';    %earths atmosphere
nsp = nSpecies(gas);
T1 = 500.;
for k=1:1:75
    T(k) = T1;
    set(gas,'Temperature',T1,'Pressure',P1,'MoleFractions',q);
    gas = equilibrate(gas, 'TP');   
    X(k,:) = moleFractions(gas);
    T1 = T1 + 250.;
end
%%
figure('Name', 'Equilibrium Composition')
maxx = max(T);
minx = min(T);
fontsize=12;
set(gca,'FontSize',fontsize,'LineWidth',2,...
    'linestyleorder',{'-','-.','--',':'},...
    'nextplot','add');
set(gca, 'Yscale', 'log');
set(gca, 'Xscale', 'linear');
axis([minx maxx 1.0E-5 1]);
plot(T(:),X(:,:));
xlabel('Temperature (K)','FontSize',fontsize);
ylabel('species mole fraction','FontSize',fontsize);
legend(speciesName(gas,1:nsp),'Location','eastoutside','Fontsize',8);

