#
# This test validates the phase concentration calculation for the KKS system
#

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 20
  ny = 20
  nz = 0
  xmin = 0
  xmax = 1
  ymin = 0
  ymax = 1
  zmin = 0
  zmax = 0
  elem_type = QUAD4
[]

# We set c and eta...
[BCs]
  # (and ca for debugging purposes)
  [./top_ca]
    type = DirichletBC
    variable = ca
    boundary = 'top'
    value = 0.111
  [../]
  [./bottom_ca]
    type = DirichletBC
    variable = ca
    boundary = 'bottom'
    value = 0.111
  [../]
  [./left_ca]
    type = DirichletBC
    variable = ca
    boundary = 'left'
    value = 0.111
  [../]
  [./right_ca]
    type = DirichletBC
    variable = ca
    boundary = 'right'
    value = 0.111
  [../]

  [./left]
    type = DirichletBC
    variable = c
    boundary = 'left'
    value = 0.1
  [../]
  [./right]
    type = DirichletBC
    variable = c
    boundary = 'right'
    value = 0.9
  [../]
  [./top]
    type = DirichletBC
    variable = eta
    boundary = 'top'
    value = 0.1
  [../]
  [./bottom]
    type = DirichletBC
    variable = eta
    boundary = 'bottom'
    value = 0.9
  [../]
[]

[Variables]
  # concentration
  [./c]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.5
  [../]

  # order parameter
  [./eta]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.1
  [../]

  # phase concentration a
  [./ca]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.2
  [../]

  # phase concentration b
  [./cb]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.3
  [../]
[]

[Materials]
  # simple toy free energy
  [./fa]
    type = KKSParsedMaterial
    block = 0
    f_base = Fa
    args = 'ca'
    function = 'ca^2'
  [../]
  [./fb]
    type = KKSParsedMaterial
    block = 0
    f_base = Fb
    args = 'cb'
    function = '(1-cb)^2'
  [../]

  # h(eta)
  [./h_eta]
    type = KKSHEtaPolyMaterial
    block = 0
    h_order = HIGH
    eta = eta
    outputs = exodus
  [../]
[]

[Kernels]
  #active = 'cdiff etadiff phaseconcentration chempot'
  ##active = 'cbdiff cdiff etadiff chempot'
  active = 'cadiff cdiff etadiff phaseconcentration'
  ##active = 'cadiff cbdiff cdiff etadiff'

  [./cadiff]
    type = Diffusion
    variable = ca
  [../]

  [./cbdiff]
    type = Diffusion
    variable = cb
  [../]

  [./cdiff]
    type = Diffusion
    variable = c
  [../]

  [./etadiff]
    type = Diffusion
    variable = eta
  [../]

  # ...and solve for ca and cb
  [./phaseconcentration]
    type = KKSPhaseConcentration
    ca       = ca
    variable = cb
    c        = c
    eta      = eta
  [../]

  [./chempot]
    type = KKSPhaseChemicalPotential
    variable = ca
    cb       = cb
    fa_base  = Fa
    fb_base  = Fb
  [../]
[]

[Executioner]
  type = Steady
  solve_type = 'PJFNK'
  #solve_type = 'NEWTON'
[]

#[Preconditioning]
#  [./mydebug]
#    type = FDP
#    full = true
#  [../]
#[]

[Outputs]
  file_base = kks_phase_concentration
  output_initial = false
  interval = 1
  exodus = true

  [./console]
    type = Console
    perf_log = true
    linear_residuals = true
  [../]
[]
