% Shock and Detonation Toolbox Demo Program
% 
% Compare propagating shock and stagnation point profiles using transformation 
% methodology of Hornung.
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
clear;clc;close all;
disp('demo_STG_RZ')
graphing = true;

%Rrun the programs STG and RZ first before running this program,
% save the integrator outputs as .mat files (the demo programs do this
% automatically).
load stg.mat
load rzn.mat
U1 = stg.U1;
Delta = stg.Delta;

% relationship between stagnation point distance and post shock distance
x = Delta*(1 - exp(-rzn.distance/Delta));

if (graphing)
    fontsize=14;
    font ='TimesRoman';
    set(0,'DefaultTextFontName',font,'DefaultTextFontSize',fontsize,'DefaultAxesFontName',font,'DefaultAxesFontSize',fontsize,'DefaultLineLineWidth',1,'DefaultLineMarkerSize',7.75)
    figure('Name', ['Reaction Zone Structure U = ',num2str(U1),' m/s'],'DefaultTextFontName', font, 'DefaultAxesFontName', font);
    eps = 1E-6;
    maxy = max(stg.P);
    miny = min(stg.P);
    minx = min(stg.distance)+eps;
    maxx = max(stg.distance);
    semilogx(x(1:30:end),rzn.P(1:30:end),'o-k',stg.distance,stg.P,'b');
    axis([minx maxx miny maxy]);
    xlabel('distance (m)','FontSize',fontsize);
    ylabel('pressure (Pa)','FontSize',fontsize);
    ytickformat('%,.f')
    legend('shock tube (x transformation)','stagnation flow','Location','west')
    print('-depsc2','-r600','shk-stg-P.eps')
    
    figure('Name', ['Reaction Zone Structure U = ',num2str(U1),' m/s'],'DefaultTextFontName', font, 'DefaultAxesFontName', font);
    maxy = max(stg.T);
    miny = min(stg.T);
    semilogx(x(1:30:end),rzn.T(1:30:end),'o-k',stg.distance,stg.T,'b','LineWidth',1);
    axis([minx maxx miny maxy]);
    xlabel('distance (m)','FontSize',fontsize);
    ylabel('temperature (K)','FontSize',fontsize);
    legend('shock tube (x transformation)','stagnation flow','Location','west')
    print('-depsc2','-r600','shk-stg-T.eps')
    
    figure('Name', ['Reaction Zone Structure U = ',num2str(U1),' m/s'],'DefaultTextFontName', font, 'DefaultAxesFontName', font);
    maxy = max(stg.rho);
    miny = min(stg.rho);
    semilogx(x(1:30:end),rzn.rho(1:30:end),'o-k',stg.distance,stg.rho,'b','LineWidth',1);
    axis([minx maxx miny maxy]);
    xlabel('distance (m)','FontSize',fontsize);
    ytickformat('%,.3f')
    ylabel('density (kg/m^3)','FontSize',fontsize);
    legend('shock tube (x transformation)','stagnation flow','Location','west')
    print('-depsc2','-r600','shk-stg-rho.eps')
    
    figure('Name', ['Reaction Zone Structure U = ',num2str(U1),' m/s'],'DefaultTextFontName', font, 'DefaultAxesFontName', font);
    loglog(x(1:30:end),rzn.species(1:30:end,9),'o-k',stg.distance(:),stg.species(:,9),'b');
    axis([minx maxx 1.0E-3 1]);
    xlabel('distance (m)','FontSize',fontsize);
    ytickformat('%.1e');
    yticks([1E-3 1E-2 1E-1 1E0]);
    ylabel('CO_2 mass fraction','FontSize',fontsize);
    legend('shock tube (x transformation)','stagnation flow','Location','west')
    print('-depsc2','-r600','shk-stg-co2.eps')
    
    
    figure('Name', ['Reaction Zone Structure U = ',num2str(U1),' m/s'],'DefaultTextFontName', font, 'DefaultAxesFontName', font);
    maxx = max(rzn.distance);
    minx = min(rzn.distance)+1E-6;
    maxy = max(stg.rho);
    miny = min(stg.rho);
    semilogx(rzn.distance(1:30:end),rzn.rho(1:30:end),'o-k',stg.distance,stg.rho,'b','LineWidth',1);
    axis([minx maxx miny maxy]);
    xlabel('distance (m)','FontSize',fontsize);
    ylabel('density (kg/m^3)','FontSize',fontsize);
    legend('shock tube','stagnation flow','Location','west')
    print('-depsc2','-r600','shk-stg-rho-comp-distance.eps')
    
    figure('Name', ['Reaction Zone Structure U = ',num2str(U1),' m/s'],'DefaultTextFontName', font, 'DefaultAxesFontName', font);
    maxx = max(stg.time);
    minx = min(stg.time)+1E-6;
    maxy = max(stg.rho);
    miny = min(stg.rho);
    semilogx(rzn.time(1:30:end),rzn.rho(1:30:end),'o-k',stg.time,stg.rho,'b','LineWidth',1);
    axis([minx maxx miny maxy]);
    xlabel('time (s)','FontSize',fontsize);
    ylabel('density (kg/m^3)','FontSize',fontsize);
    legend('shock tube','stagnation flow','Location','west')
    print('-depsc2','-r600','shk-stg-rho-comp-time.eps')
end

