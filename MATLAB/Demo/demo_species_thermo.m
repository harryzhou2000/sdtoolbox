%species_thermo.m
% plots data for individual species
% JES April 2016
clc;clear;close all;
plots = true;
file_out = false;
T_zero = 298.15;
P_zero = oneatm;
Tmin = 300.;
Tmax = 5000.;
T = Tmin:100:Tmax;
imax = length(T);
mech ='gri30_highT.yaml';
gas = Solution(mech);
species = {'CO2',  'H2O', 'CO', 'N2', 'OH','H','O'};
i_species = speciesIndex(gas,species);
n_species = length(i_species);
W = molecularWeights(gas);
R = gasconstant./W;
% standard state value
set(gas, 'T', T_zero, 'P', oneatm);
cp_all = cp_R(gas);
CP_R_zero = cp_all(i_species);
h_rt_all = enthalpies_RT(gas);
H_RT_zero = h_rt_all(i_species);
H_zero = H_RT_zero.*gasconstant*T_zero;
s_r_all = entropies_R(gas);
S_R_zero = s_r_all(i_species); 
G_0 = (H_RT_zero -S_R_zero)*T_zero*gasconstant;

% values as a function of temperature 
for i=1:imax
    set(gas, 'T', T(i), 'P', oneatm);
    cp_all(:,i) = cp_R(gas);
    h_rt_all(:,i) = enthalpies_RT(gas);
    s_r_all(:,i) = entropies_R(gas);
    CP_R(:,i) = cp_all(i_species,i);
    H_RT(:,i) = h_rt_all(i_species,i);
    S_R(:,i) = s_r_all(i_species,i);
    G(:,i) = (H_RT(:,i)-S_R(:,i))*gasconstant*T(i);
    DH(:,i) = gasconstant*T(i)*H_RT(:,i)- H_zero;
end


display(['Mechanism: ',mech]);
display(' ')
for i = 1:n_species
    display(['Standard state values for ',species{i}]);
    display(' ')
    display(['Cp/R               ', num2str(CP_R_zero(i))]);
    display(['S/R                ', num2str(S_R_zero(i))]);
    display(['Delta H_f0 (kJ/mol) ' , num2str(H_zero(i)/1E6)]);
    display(['G_0 (kJ/mol) ' , num2str(G_0(i)/1E6)]);
    display(['W (kg/kmol) ' , num2str(W(i_species(i)))]);
    display(' ')
end

% plot thermo data vs temperature
if (plots)
    fig_1 = figure('Name','Cantera thermo Cp/R' );
    maxx = max(T(:));
    minx = min(T(:));
    fontsize=12;
    xlim([minx maxx]);
    hold on
    set(gca,'FontSize',fontsize,'LineWidth',2);
    plot(T(:),CP_R(:,:),'LineWidth',2);
    xlabel('T (K)','FontSize',fontsize);
    ylabel('C_p/R','FontSize',fontsize);
    legend(species,'Location','southeast')
    hold off
    
    fig_2 = figure('Name','Cantera thermo H/RT' );
     maxx = max(T(:));
    minx = min(T(:));
    fontsize=12;
    xlim([minx maxx]);
    hold on;
    set(gca,'FontSize',fontsize,'LineWidth',2);
    plot(T(:),H_RT(:,:),'LineWidth',2);
    xlabel('T (K)','FontSize',fontsize);
    ylabel('h/RT','FontSize',fontsize);
    legend(species,'Location','southeast')
    hold off
    
    fig_3 = figure('Name','Cantera thermo S/R' );
    maxx = max(T(:));
    minx = min(T(:));
    fontsize=12;
     xlim([minx maxx]);
    hold on;
    set(gca,'FontSize',fontsize,'LineWidth',2);
    plot(T(:),S_R(:,:),'LineWidth',2);
    xlabel('T (K)','FontSize',fontsize);
    ylabel('S/R','FontSize',fontsize);
    legend(species,'Location','southeast')
    hold off

    fig_4 = figure('Name','Cantera thermo G' );
    maxx = max(T(:));
    minx = min(T(:));
    fontsize=12;
    xlim([minx maxx]);
    hold on;
    set(gca,'FontSize',fontsize,'LineWidth',2);
    plot(T(:),G(:,:)/1E6,'linewidth',2);
    xlabel('T (K)','FontSize',fontsize);
    ylabel('G [kJ/mol]','FontSize',fontsize);
    legend(species,'Location','southwest')
    hold off

    fig_5 = figure('Name','Cantera thermo H' );
    maxx = max(T(:));
    minx = min(T(:));
    fontsize=12;
    xlim([minx maxx]);
    hold on;
    set(gca,'FontSize',fontsize,'LineWidth',2);
    plot(T(:),(DH(:,:)+H_zero)/1E6,'LineWidth',2);
    xlabel('T (K)','FontSize',fontsize);
    ylabel('H [kJ/mol]','FontSize',fontsize);
    legend(species,'Location','southeast')
    hold off
end
if (file_out)
    for i = 1:n_species
        file_name = [mech,'_',species{i},'_thermo.xlsx'];
        A1 = [T_zero,CP_R_zero(i)*gasconstant/1E3,(gasconstant*H_RT_zero(i)*T_zero-H_zero(i))/1E6,S_R_zero(i)*gasconstant/1E3, gasconstant*T_zero*(H_RT_zero(i)-S_R_zero(i))/1E6];
        A = [A1;[T',CP_R(i,:)'*gasconstant/1E3,DH(i,:)'/1E6,S_R(i,:)'*gasconstant/1E3,G(i,:)'/1E6]] ;
        writematrix(A,file_name);
    end
end
