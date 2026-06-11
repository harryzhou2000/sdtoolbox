"""
Shock and Detonation Toolbox Demo Program

Calculates post-relected-shock state for a specified shock speed and a specified 
initial mixture.  In this demo, both shocks are reactive, i.e. the computed states 
behind both the incident and reflected shocks are EQUILIBRIUM states.  
The reflected state is computed by the SDToolbox function reflected_eq.

################################################################################
Theory, numerical methods and applications are described in the following report:

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
import cantera as ct
from sdtoolbox.postshock import CJspeed, PostShock_eq
from sdtoolbox.reflections import reflected_eq

# Initial state specification:
# P1 = Initial Pressure  
# T1 = Initial Temperature 
# U = Shock Speed 
# q = Initial Composition 
# mech = Cantera mechanism File name
P1 = 100000
T1 = 300
q = 'H2:2 O2:1 N2:3.76'    
mech = 'H2O2.yaml'         
gas1 = ct.Solution(mech)
gas1.TPX = T1, P1, q

print ('Initial state: ' + q + ', P1 = %.2f Pa,  T1 = %.2f K' % (P1,T1) )
print ('Mechanism: ' + mech)

# create gas objects for other states
gas2 = ct.Solution(mech)
gas3 = ct.Solution(mech)

# compute minimum incident wave speed
fig_num = 0;
cj_speed = CJspeed(P1, T1, q, mech)  
# incident wave must be greater than or equal to cj_speed for
# equilibrium computations
UI = 1.2*cj_speed

print('Incident shock speed UI = %.2f m/s' % (UI))

# compute postshock gas state object gas2
gas2 = PostShock_eq(UI, P1, T1, q, mech);

print ('Equilibrium Post-Incident-Shock State')
print ('T2 = %.2f K, P2 = %.2f Pa' % (gas2.T,gas2.P))

# compute reflected shock post-shock state gas3
[p3,UR,gas3]= reflected_eq(gas1,gas2,gas3,UI);
# Outputs:
# p3 - pressure behind reflected wave
# UR = Reflected shock speed relative to reflecting surface
# gas3 = gas object with properties of postshock state

print ('Equilibrium Post-Reflected-Shock State')
print ('T3 = %.2f K,  P3 = %.2f Pa' % (gas3.T,gas3.P))
print ("Reflected Wave Speed = %.2f m/s" % (UR))

# gas states
print('Incident gas state')
gas1()
print('Post-incident-shock gas state')
gas2()
print('Post-reflected-schock gas state')
gas3()
