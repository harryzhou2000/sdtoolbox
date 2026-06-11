"""
species_thermo.py
Plots thermodynamic data for individual species using Cantera.
Translated from MATLAB (species_thermo.m, JES April 2016)
"""

import numpy as np
import matplotlib.pyplot as plt
import cantera as ct
import pandas as pd  # only needed if file_out = True

# ── Settings ──────────────────────────────────────────────────────────────────
plots    = True
file_out = True

# ── Constants & temperature range ─────────────────────────────────────────────
T_zero = 298.15                        # K  (MATLAB: T_zero = 298.15)
P_zero = ct.one_atm                    # Pa (MATLAB: oneatm)
Tmin   = 300.0
Tmax   = 5000.0
T      = np.arange(Tmin, Tmax + 1, 100)   # MATLAB: Tmin:100:Tmax
imax   = len(T)

# ── Load mechanism & choose species ───────────────────────────────────────────
mech    = "gri30_highT.yaml"
gas     = ct.Solution(mech)            # MATLAB: gas = Solution(mech)

species   = ["CO2",  "H2O", "CO", "N2", "OH", "H", "O"]
# Cantera Python uses 0-based indices; MATLAB speciesIndex returns 1-based
i_species = [gas.species_index(sp) for sp in species]   # MATLAB: speciesIndex(gas, species)
n_species = len(i_species)

W  = gas.molecular_weights             # kg/kmol  — MATLAB: molecularWeights(gas)
R  = ct.gas_constant / W              # J/(mol·K) per species

# ── Standard-state values (T_zero, P_zero) ────────────────────────────────────
gas.TP = T_zero, ct.one_atm           # MATLAB: set(gas, 'T', T_zero, 'P', oneatm)

CP_R_zero = gas.standard_cp_R[i_species]       # MATLAB: cp_R(gas)
H_RT_zero = gas.standard_enthalpies_RT[i_species]   # MATLAB: enthalpies_RT(gas)
H_zero    = H_RT_zero * ct.gas_constant * T_zero    # J/mol
S_R_zero  = gas.standard_entropies_R[i_species]     # MATLAB: entropies_R(gas)
G_0       = (H_RT_zero - S_R_zero) * T_zero * ct.gas_constant  # J/mol

# ── Arrays over temperature range ─────────────────────────────────────────────
# Shape: (n_species, imax)  — MATLAB uses (n_species, imax) column layout too
CP_R = np.zeros((n_species, imax))
H_RT = np.zeros((n_species, imax))
S_R  = np.zeros((n_species, imax))
G    = np.zeros((n_species, imax))
DH   = np.zeros((n_species, imax))

for i, Ti in enumerate(T):            # MATLAB: for i=1:imax
    gas.TP = Ti, ct.one_atm
    CP_R[:, i] = gas.standard_cp_R[i_species]
    H_RT[:, i] = gas.standard_enthalpies_RT[i_species]
    S_R[:, i]  = gas.standard_entropies_R[i_species]
    G[:, i]    = (H_RT[:, i] - S_R[:, i]) * ct.gas_constant * Ti
    DH[:, i]   = ct.gas_constant * Ti * H_RT[:, i] - H_zero

# ── Print standard-state summary ──────────────────────────────────────────────
print(f"Mechanism: {mech}")
print()
for i in range(n_species):
    print(f"Standard state values for {species[i]}")
    print(f"  Cp/R                {CP_R_zero[i]:.6g}")
    print(f"  S/R                 {S_R_zero[i]:.6g}")
    print(f"  Delta H_f0 (kJ/mol) {H_zero[i] / 1e6:.6g}")   # /1e6 → MJ → same scale as MATLAB
    print(f"  G_0 (kJ/mol)        {G_0[i] / 1e6:.6g}")
    print(f"  W (kg/kmol)         {W[i_species[i]]:.6g}")
    print()

# ── Plots ──────────────────────────────────────────────────────────────────────
if plots:
    fig_cfg = dict(figsize=(7, 4))

    def _fmt(ax, xlabel, ylabel):
        ax.set_xlim(T[0], T[-1])
        ax.set_xlabel(xlabel, fontsize=12)
        ax.set_ylabel(ylabel, fontsize=12)
        ax.tick_params(labelsize=12)
        for spine in ax.spines.values():
            spine.set_linewidth(2)

    # Cp/R
    fig, ax = plt.subplots(**fig_cfg)
    ax.plot(T, CP_R.T, linewidth=2)           # .T because plot expects (imax, n_species)
    _fmt(ax, "T (K)", r"$C_p/R$")
    ax.legend(species, loc="lower right")
    fig.canvas.manager.set_window_title("Cantera thermo Cp/R")

    # H/RT
    fig, ax = plt.subplots(**fig_cfg)
    ax.plot(T, H_RT.T, linewidth=2)
    _fmt(ax, "T (K)", r"$h/RT$")
    ax.legend(species, loc="lower right")
    fig.canvas.manager.set_window_title("Cantera thermo H/RT")

    # S/R
    fig, ax = plt.subplots(**fig_cfg)
    ax.plot(T, S_R.T, linewidth=2)
    _fmt(ax, "T (K)", r"$S/R$")
    ax.legend(species, loc="lower right")
    fig.canvas.manager.set_window_title("Cantera thermo S/R")

    # G
    fig, ax = plt.subplots(**fig_cfg)
    ax.plot(T, G.T / 1e6, linewidth=2)
    _fmt(ax, "T (K)", r"$G$ [kJ/mol]")
    ax.legend(species, loc="lower left")
    fig.canvas.manager.set_window_title("Cantera thermo G")

    # ΔH
    fig, ax = plt.subplots(**fig_cfg)
    ax.plot(T, (DH.T + H_zero)/ 1e6, linewidth=2)
    _fmt(ax, "T (K)", r"$ H$ [kJ/mol]")
    ax.legend(species, loc="lower right")
    fig.canvas.manager.set_window_title("Cantera thermo H")

    plt.tight_layout()
    plt.show()

# ── Optional file output ───────────────────────────────────────────────────────
if file_out:
    for i in range(n_species):
        file_name = f"{mech}_{species[i]}_thermo.xlsx"
        header_row = np.array([[
            T_zero,
            CP_R_zero[i] * ct.gas_constant / 1e3,
            (ct.gas_constant * H_RT_zero[i] * T_zero) / 1e6,
            S_R_zero[i] * ct.gas_constant / 1e3,
            ct.gas_constant * T_zero * (H_RT_zero[i] - S_R_zero[i]) / 1e6,
        ]])
        data_rows = np.column_stack([
            T,
            CP_R[i, :] * ct.gas_constant / 1e3,
            DH[i, :] / 1e6,
            S_R[i, :] * ct.gas_constant / 1e3,
            G[i, :] / 1e6,
        ])
        A = np.vstack([header_row, data_rows])
        cols = ["T (K)", "Cp (kJ/mol/K)", "DeltaH (MJ/mol)", "S (kJ/mol/K)", "G (MJ/mol)"]
        pd.DataFrame(A, columns=cols).to_excel(file_name, index=False)
        print(f"Wrote {file_name}")
