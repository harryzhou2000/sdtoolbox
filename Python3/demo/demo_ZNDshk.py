"""
Shock and Detonation Toolbox Demo Program

Generate plots and output files for a ZND detonation with the shock front traveling at speed U.
For exothermic reactions, U > U_CJ


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
from sdtoolbox.postshock import PostShock_fr
from sdtoolbox.znd import zndsolve
from sdtoolbox.utilities import znd_plot, znd_fileout
import cantera as ct

P1 = 100000 
T1 = 300
U1 = 3000
q = 'H2:2 O2:1 N2:3.76'
mech = 'H2O2.yaml'
file_name = 'h2air'

# Set up gas object
gas1 = ct.Solution(mech)
gas1.TPX = T1,P1,q

# Find post shock state for given speed
gas = PostShock_fr(U1, P1, T1, q, mech)

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
znd_out = zndsolve(gas,gas1,U1,relTol=1e-6,absTol=1e-7,t_end=1e-6,max_step=1e-8, advanced_output=True,Method='LSODA')
znd_plot(znd_out,xscale='log',maxx=1E-4,major_species=['H2', 'O2', 'H2O', 'N2'],minor_species=['H', 'O', 'OH','H2O2','HO2'])
znd_fileout(file_name,znd_out)

print('Reaction zone pulse width (exothermic length) = %.4g m' % znd_out['exo_len_ZND'])
print('Reaction zone induction length = %.4g m' % znd_out['ind_len_ZND'])
print('Reaction zone pulse time (exothermic time) = %.4g s' % znd_out['exo_time_ZND'])
print('Reaction zone induction time = %.4g s' % znd_out['ind_time_ZND'])
