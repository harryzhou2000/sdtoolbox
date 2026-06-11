"""
Shock and Detonation Toolbox Demo Program

Calculate the FROZEN post shock state based on the initial gas 
state and the shock speed.  Evaluates the shock jump conditions using a fixed
composition using SDToolbox function PostShock_fr.

################################################################################
Theory, numerical methods and applications are described in the
following report:

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
from sdtoolbox.postshock import PostShock_fr

# Initial state specification:
# P1 = Initial Pressure  
# T1 = Initial Temperature 
# U = Shock Speed 
# q = Initial Composition 
# mech = Cantera mechanism File name

P1 = 100000; P1atm = P1/ct.one_atm
T1 = 300
U = 2000
q = 'H2:2 O2:1 N2:3.76'
mech = 'H2O2.yaml'
 
gas = PostShock_fr(U, P1, T1, q, mech)
Ps = gas.P/ct.one_atm

print(' ')
print('Initial state: ' + q + ', P1 = %.2f atm,  T1 = %.2f K' % (P1atm,T1) )
print('Mechanism: ' + mech)
print('Frozen postshock state: Ps = %.2f atm, Ts = %.2f K' % (Ps,gas.T))
print(' ')
