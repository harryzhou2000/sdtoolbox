"""
Shock and Detonation Toolbox Demo Program

Computes ZND and CV models of detonation with the shock front
traveling at the CJ speed.  Evaluates various measures of the reaction
zone thickness and exothermic pulse width, and effective activation energy. 
 
################################################################################
SDToolbox:  Numerical Tools for Shock and Detonation Wave Modeling.  
S. T. Kao, J. L. Zeigler, N. P. Bitter, B. E. Schmidt, J. M. Lawson, and J. E. Shepherd. 
GALCIT Report FM2018.001.  California Institute of Technology, 2023. 
https://shepherd.caltech.edu/EDL/PublicResources/sdt/doc/ShockDetonation/ShockDetonation.pdf

Please cite this report and the website: http://shepherd.caltech.edu/EDL/PublicResources/sdt/ 
if you use these routines. Refer to LICENCE.txt or the above report for copyright and disclaimers.

Updated April 2026
Requires Cantera Version 3.0 or higher, see https://cantera.org/ for downloads and documentation
Tested with Python 3.12 and Cantera 3.0
"""
from sdtoolbox.postshock import CJspeed, PostShock_fr, PostShock_eq
from sdtoolbox.znd import zndsolve
from sdtoolbox.cv import cvsolve
from sdtoolbox.utilities import CJspeed_plot, znd_plot
import cantera as ct
import numpy as np


P1 = 100000; T1 = 300
q = 'H2:2 O2:1 N2:3.76'
mech = 'H2O2.yaml'
fname = 'h2air'

# Find CJ speed and related data, make CJ diagnostic plots
cj_speed,R2,plot_data = CJspeed(P1,T1,q,mech,fullOutput=True)
CJspeed_plot(plot_data,cj_speed)

# Set up gas object
gas1 = ct.Solution(mech)
gas1.TPX = T1,P1,q

# Find equilibrium post shock state for given speed
gas = PostShock_eq(cj_speed, P1, T1, q, mech)
u_cj = cj_speed*gas1.density/gas.density

# Find frozen post shock state for given speed
gas = PostShock_fr(cj_speed, P1, T1, q, mech)

# Solve ZND ODEs, make ZND plots
out = zndsolve(gas,gas1,cj_speed,t_end=1e-3,advanced_output=True)

# Find CV parameters including effective activation energy
gas.TPX = T1,P1,q
gas = PostShock_fr(cj_speed, P1, T1, q, mech)
Ts = gas.T; Ps = gas.P
Ta = Ts*1.02
gas.TPX = Ta,Ps,q
CVout1 = cvsolve(gas)
Tb = Ts*0.98
gas.TPX = Tb,Ps,q
CVout2 = cvsolve(gas)
# Approximate effective activation energy for CV explosion
taua = CVout1['ind_time']
taub = CVout2['ind_time']
if taua==0 and taub==0:
    theta_effective_CV = 0
else:
    theta_effective_CV = 1/Ts*((np.log(taua)-np.log(taub))/((1/Ta)-(1/Tb)))

print('ZND computation results; ')
print('Reaction zone computation end time = {:8.3e} s'.format(out['tfinal']))
print('Reaction zone computation end distance = {:8.3e} m'.format(out['xfinal']))
print(' ')
print('T (K), initial = {:1.5g}, final = {:1.5g}, max = {:1.5g} K'.format(out['T'][0],out['T'][-1],max(out['T'])))
print('P (Pa), initial = {:1.5g}, final = {:1.5g}, max = {:1.5g} K'.format(out['P'][0],out['P'][-1],max(out['P'])))
print('M, initial = {:1.5g}, final = {:1.5g}, max = {:1.5g}'.format(out['M'][0],out['M'][-1],max(out['M'])))
print('u (m/s), initial = {:1.5g}, final = {:1.5g}, u_cj = {:1.5g}'.format(out['U'][0],out['U'][-1],u_cj))
print(' ')
print('Reaction zone thermicity half-width = {:8.3e} m'.format(out['exo_len_ZND']))
print('Reaction zone maximum thermicity distance = {:8.3e} m'.format(out['ind_len_ZND']))
print('Reaction zone thermicity half-time = {:8.3e} s'.format(out['exo_time_ZND']))
print('Reaction zone maximum thermicity time = {:8.3e} s'.format(out['ind_time_ZND']))
print(' ')
print('CV computation results; ')
print('Time to dT/dt_max = {:8.3e} s'.format(CVout1['ind_time']))
print('Distance to dT/dt_max = {:8.3e} m'.format(CVout1['ind_time']*out['U'][0]))
print('Reduced activation energy) = {:8.3e}'.format(theta_effective_CV))


znd_plot(out,maxx=0.001,
         major_species=['H2', 'O2', 'H2O'],
         minor_species=['H', 'O', 'OH', 'H2O2', 'HO2'])


