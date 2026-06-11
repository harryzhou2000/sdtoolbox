"""
Shock and Detonation Toolbox Demo Program

Generate plots and output files for a ZND detonation with the shock front
traveling at the CJ speed.

################################################################################
Theory, numerical methods and applications are described in the following report:

SDToolbox - Numerical Tools for Shock and Detonation Wave Modeling,
Explosion Dynamics Laboratory, Contributors: S. Browne, J. Ziegler,
N. Bitter, B. Schmidt, J. Lawson and J. E. Shepherd, GALCIT
Technical Report FM2018.001 Revised January 2021.

Please cite this report and the website if you use these routines. 

Please refer to LICENCE.txt or the above report for copyright and disclaimers.

http://shepherd.caltech.edu/EDL/PublicResources/sdt/

################################################################################ 
Updated September 2018
Tested with: 
    Python 3.5 and 3.6, Cantera 2.3 and 2.4
Under these operating systems:
    Windows 8.1, Windows 10, Linux (Debian 9)
"""

from sdtoolbox.postshock import CJspeed, PostShock_fr
from sdtoolbox.znd import zndsolve
from sdtoolbox.utilities import CJspeed_plot, znd_plot, znd_fileout
import cantera as ct

P1 = 20000. 
T1 = 300.
q = 'CH4:1 O2:2 N2:1.25'
mech = 'gri30_highT.yaml'
file_name = 'CH4_air'


# Find CJ speed and related data, make CJ diagnostic plots
cj_speed,R2,plot_data = CJspeed(P1,T1,q,mech,fullOutput=True)
CJspeed_plot(plot_data,cj_speed)

# Set up gas object
gas1 = ct.Solution(mech)
gas1.TPX = T1,P1,q

# Find post shock state for given speed, start slightly above CJ for this case to avoid
# getting stuck at sonic point
U = 1.005*cj_speed
gas = PostShock_fr(U, P1, T1, q, mech)

"""
CAUTIONS:
If you have trouble getting a converged solution with the ode solver, this is usually associated with
large mechanisms for hydrocarbons. There are often species that are present in very small
amounts at the end of the reaction zone and change rapidly in the energy release portion of the
reaction zone. Although these are not important for obtaining a solution, if the solver takes too large a
time step, negative species amounts will result in an error.  Implicit solvers that automatically adjust the time step
can run into trouble if there is a sudden change in conditions, which happens within energy release zone for compositions and conditions with long induction zone and short energy release zone. 


There are three approaches to dealing with these problems.

1.Switch solvers.
a. For python,  use "LSODA" or "BDF", these are more robust alternatives to the 'Radau' solver that was originally used.  A method
parameter has been added to the calls and the default is being changed to 'LSODA'.
b.  For Matlab,  try "ode23tb" instead of the "ode15s" that is the default.  However, it is often necessary to reduce the max_step
and tolerances for Matlab.

2. Reduce the tolerance paramters, "absTol", "relTol"

3.  Reduce the "max_step" parameter   

Examine the species (particularly the minor species) near the energy
release region to  determine what sort of abs_tol and max_step are needed.  The values can be surprisingly small in order to
avoid oscillations in species concentrations.  

"""

# Solve ZND ODEs, make ZND plots
znd_out = zndsolve(gas,gas1,U,relTol=1e-7,absTol=1e-8,t_end=5e-5, advanced_output=True,Method='LSODA')
znd_plot(znd_out,xscale='log',maxx=10E-3,major_species=['CH4', 'O2', 'H2O', 'CO2'],minor_species=['H', 'O', 'OH', 'CH2O','CO', 'H2'])
znd_fileout(file_name,znd_out)

print('Reaction zone pulse width (exothermic length) = %.4g m' % znd_out['exo_len_ZND'])
print('Reaction zone induction length = %.4g m' % znd_out['ind_len_ZND'])
print('Reaction zone pulse time (exothermic time) = %.4g s' % znd_out['exo_time_ZND'])
print('Reaction zone induction time = %.4g s' % znd_out['ind_time_ZND'])
