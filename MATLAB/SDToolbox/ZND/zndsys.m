function dydt = zndsys(t,y,gas,U1,r1,PSC)
% Shock and Detonation Toolbox
% http://shepherd.caltech.edu/EDL/public/cantera/html/SD_Toolbox/
%
% ZNDReactor.m - Set of ODE's to solve ZND Detonation Problem
%
% FUNCTION
% SYNTAX
% dydt = ZNDReactor(t,y,gas,U1,r1,PSC)
% ALWAYS called by an ODE solver, in this case: out = ode15s(@ZNDReactor,tel,y0,options,gas,U1,r1,PSC)
%       tel = time span
%       y0 = initial conditions array
%       options = specified in znd.m
%       gas = Cantera gas object
%       U1 = Shock Velocity
%       r1 = initial density
%       PSC = Post-shock pressure
%
% INPUT
% t = time
% y = solution array [pressure, density, position, species mass 1, 2, ..]
% gas = Cantera gas object
% U1 = Shock Velocity
% r1 = initial density
% PSC = Post-shock pressure
%
% OUTPUT
% dydt = Array of ODEs to be solved by ode15s  
% dydt = [dpressuredt, ddensitydt, dpostiondt,dmass1dt, dmass2dt, ...]
%
% SUBFUNCTION CALLS
% Cantera Functions: set.m, meanMolecularWeight.m, gasconstant.m,
%       density.m, nSpecies.m, netProdRates.m, enthalpies_RT.m,
%       molecularWeights.m, cp_mass.m, soundspeed.m,  

set(gas, 'Rho', y(2), 'Y', y(4:end));
wt = meanMolecularWeight(gas);
rho = density(gas);
T = (y(1)*PSC/y(2))*(wt/gasconstant);
set(gas, 'T', T, 'Rho', rho, 'Y', y(4:end));
nsp = nSpecies(gas);

%Vectors
wdot = netProdRates(gas);
hs = enthalpies_RT(gas)*gasconstant*T;
mw = molecularWeights(gas);

%Scalars
cp = cp_mass(gas);
c = soundspeed(gas);

U = U1*r1/rho;
M = U/c;                       %Mach Number
eta = 1 - M^2;                 %Sonic Parameter
 
% Loop through all of the species,calculate thermicity for this time step
sum = 0;
for z = 1:nsp
    dykdt(z) = mw(z)*wdot(z)/rho; %Net production rate of species z (kg/sec)
    drdy = -wt/mw(z); % mean molecular weight / molecular weight of species z
    a = hs(z)/(cp*T*mw(z));  % factor that accounts for chemical energy change
    sum = sum - (drdy + a)*dykdt(z);
end
sigmadot = sum;                   %Thermicity

Pdot = -rho*U^2*sigmadot/eta/PSC;   %Pressure Derivative (Normalized by Post-Shock pressure to reduce size)
rdot = -rho*sigmadot/eta;           %Density Derivative
%xdot = U;                      %Distance Derivative

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
% SET UP COLUMN VECTOR FOR SOLUTION DYDT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dydt = [ Pdot
         rdot
         U
         zeros(nsp,1) ];

% species equations 
for i = 1:nsp
  dydt(i+3) = mw(i)*wdot(i)/rho; % mass production rates
end
