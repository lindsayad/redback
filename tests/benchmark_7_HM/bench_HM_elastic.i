# An undrained oedometer test on a saturated poroelastic sample
# to compare with MOOSE poromechanics test.
#
# The sample is a single unit element, with roller BCs on the sides
# and bottom.  A constant displacement is applied to the top: disp_z = -0.01*t.
# There is no fluid flow.
#
# Under these conditions
# porepressure = -(Biot coefficient)*(Biot modulus)*disp_z/L
# stress_xx = (bulk - 2*shear/3)*strain_zz (remember this is effective stress)
# stress_zz = (bulk + 4*shear/3)*strain_zz (remember this is effective stress)
# where L is the height of the sample (L=1 in this test),
#  strain_zz = v_z * t /L + 0.5*[v_z * t /L]^2   (in finite strain)
#
# Parameters:
# Biot coefficient = 0.3
# Porosity = 0.1
# Bulk modulus = 2
# Shear modulus = 1.5
# fluid bulk modulus = 1/0.3 = 3.333333
# 1/Biot modulus = (1 - 0.3)*(0.3 - 0.1)/2 + 0.1*0.3 = 0.1. BiotModulus = 10
#
# Desired output:
# zdisp = -0.01*t
# p0 = 0.03*t
# stress_xx = stress_yy = -0.01*t - 5e-5*t^2
# stress_zz = -0.04*t - 2e-4*t^2

[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 1
  ny = 1
  nz = 1
  xmin = -0.5
  xmax = 0.5
  ymin = -0.5
  ymax = 0.5
  zmin = -0.5
  zmax = 0.5
[]

[Variables]
  active = 'pore_pressure disp_z disp_y disp_x'
  [./disp_x]
    order = FIRST
    family = LAGRANGE
  [../]
  [./disp_y]
    order = FIRST
    family = LAGRANGE
  [../]
  [./disp_z]
    order = FIRST
    family = LAGRANGE
  [../]
  [./temp]
  [../]
  [./pore_pressure]
  [../]
[]

[GlobalParams]
  time_factor = 10
[]

[Materials]
  [./mat_mech]
    type = RedbackMechMaterialElastic
    block = 0
    disp_x = disp_x
    disp_y = disp_y
    pore_pres = pore_pressure
    exponent = 0
    fill_method = symmetric_isotropic
    C_ijkl = '1.0 1.5' # young = 3.6, poisson = 0.2
    ref_pe_rate = 0
    yield_stress = '0. 1 1. 1'
    total_porosity = 0.1
    disp_z = disp_z
  [../]
  [./mat_nomech]
    type = RedbackMaterial
    block = 0
    disp_x = disp_x
    disp_y = disp_y
    pore_pres = pore_pressure
    Aphi = 0
    ar = 0
    ar_F = 0
    ar_R = 0
    eta1 = 0
    gr = 0 # exp(-Ar), Ar=10
    phi0 = 0.1
    ref_lewis_nb = 1
    total_porosity = 0.1
    Peclet_number = 1
    solid_density = 0
    disp_z = disp_z
    confining_pressure = 0
    delta = 0
    is_mechanics_on = true
    fluid_density = 0
    eta2 = 0
    solid_compressibility = 3.7037 # 1/(0.9*0.3)
  [../]
[]

[BCs]
  [./confinex]
    type = PresetBC
    variable = disp_x
    boundary = 'left right'
    value = 0
  [../]
  [./confiney]
    type = PresetBC
    variable = disp_y
    value = 0
    boundary = 'bottom top'
  [../]
  [./basefixed]
    type = PresetBC
    variable = disp_z
    value = 0
    boundary = back
  [../]
  [./top_velocity]
    type = FunctionPresetBC
    variable = disp_z
    function = -0.01*t
    boundary = front
  [../]
[]

[AuxVariables]
  active = 'stress_yy stress_xz stress_xx stress_xy stress_zz stress_yz'
  [./total_porosity]
    order = FIRST
    family = MONOMIAL
  [../]
  [./stress_xx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_xy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_xz]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_yy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_yz]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_zz]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Kernels]
  active = 'td_press poromech'
  [./td_temp]
    type = TimeDerivative
    variable = temp
  [../]
  [./temp_diff]
    type = Diffusion
    variable = temp
  [../]
  [./temp_dissip]
    type = RedbackMechDissip
    variable = temp
  [../]
  [./temp_endo_chem]
    type = RedbackChemEndo
    variable = temp
  [../]
  [./td_press]
    type = TimeDerivative
    variable = pore_pressure
  [../]
  [./press_diff]
    type = RedbackMassDiffusion
    variable = pore_pressure
  [../]
  [./chem_press]
    type = RedbackChemPressure
    variable = pore_pressure
    block = 0
  [../]
  [./thermal_pressurization]
    type = RedbackThermalPressurization
    variable = pore_pressure
    temperature = temp
  [../]
  [./poromech]
    type = RedbackPoromechanics
    variable = pore_pressure
  [../]
[]

[AuxKernels]
  active = 'stress_yy stress_xz stress_xx stress_xy stress_zz stress_yz'
  [./total_porosity]
    type = RedbackTotalPorosityAux
    variable = total_porosity
    mechanical_porosity = mech_porosity
  [../]
  [./stress_xx]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xx
    index_i = 0
    index_j = 0
  [../]
  [./stress_xy]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xy
    index_i = 0
    index_j = 1
  [../]
  [./stress_xz]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xz
    index_i = 0
    index_j = 2
  [../]
  [./stress_yy]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_yy
    index_i = 1
    index_j = 1
  [../]
  [./stress_yz]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_yz
    index_i = 1
    index_j = 2
  [../]
  [./stress_zz]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_zz
    index_i = 2
    index_j = 2
  [../]
[]

[Postprocessors]
  [./p0]
    type = PointValue
    point = '0 0 0'
    variable = pore_pressure
  [../]
  [./zdisp]
    type = PointValue
    point = '0 0 0.5'
    variable = disp_z
  [../]
  [./stress_xx]
    type = PointValue
    point = '0 0 0'
    variable = stress_xx
  [../]
  [./stress_yy]
    type = PointValue
    point = '0 0 0'
    variable = stress_yy
  [../]
  [./stress_zz]
    type = PointValue
    point = '0 0 0'
    variable = stress_zz
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
    petsc_options_iname = '-ksp_type -pc_type -snes_atol -snes_rtol -snes_max_it'
    petsc_options_value = 'bcgs bjacobi 1E-14 1E-10 10000'
  [../]
[]

[Executioner]
  type = Transient
  solve_type = Newton
  start_time = 0
  end_time = 10
  dt = 1
[]

[Outputs]
  exodus = false
  execute_on = timestep_end
  file_base = bench_HM_elastic
  csv = true
[]

[RedbackMechAction]
  [./solid]
    disp_x = disp_x
    disp_y = disp_y
    disp_z = disp_z
    pore_pres = pore_pressure
  [../]
[]
