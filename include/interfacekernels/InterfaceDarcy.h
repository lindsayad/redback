//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef INTERFACEDARCY_H
#define INTERFACEDARCY_H

#include "InterfaceKernel.h"

// Forward Declarations
class InterfaceDarcy;

template <>
InputParameters validParams<InterfaceDarcy>();

/**
 * DG kernel for interfacing diffusion between two variables on adjacent blocks
 */
class InterfaceDarcy : public InterfaceKernel
{
public:
  InterfaceDarcy(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual(Moose::DGResidualType type);
  virtual Real computeQpJacobian(Moose::DGJacobianType type);

  const MaterialProperty<Real> & _Le;
  const VariableValue & _Le_fault;
  const MaterialProperty<RealVectorValue> & _gravity_term;
  Real _thickness;
};

#endif
