/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/*     REDBACK - Rock mEchanics with Dissipative feedBACKs      */
/*                                                              */
/*              (c) 2014 CSIRO and UNSW Australia               */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*            Prepared by CSIRO and UNSW Australia              */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/

#include "InterfaceStress.h"
#include "RankTwoScalarTools.h"
#include "RankTwoTensor.h"
#include <cmath>

registerMooseObject("RedbackApp", InterfaceStress);

template <>
InputParameters
validParams<InterfaceStress>()
{
  InputParameters params = validParams<InterfaceKernel>();
  params.addRequiredParam<MaterialPropertyName>("stress_master",
                                                "The rank two material tensor name");
  params.addRequiredParam<MaterialPropertyName>("stress_slave",
                                                "The rank two material tensor name");
  params.addRequiredRangeCheckedParam<unsigned int>(
      "component",
      "component >= 0 & component <= 2",
      "An integer corresponding to the direction the variable "
      "this kernel acts in. (0 for x, 1 for y, 2 for z)");
  return params;
}

InterfaceStress::InterfaceStress(const InputParameters & parameters)
  : InterfaceKernel(parameters),
    _stress0(getMaterialProperty<RankTwoTensor>("stress_master")),
    _stress1(getMaterialProperty<RankTwoTensor>("stress_slave")),
    _component(getParam<unsigned int>("component"))
{
  if (!parameters.isParamValid("boundary"))
  {
    mooseError("In order to use the InterfaceStress dgkernel, you must specify a boundary where "
               "it will live.");
  }
}

Real
InterfaceStress::computeQpResidual(Moose::DGResidualType type)
{
  // continuity of each component of traction: sigma_ij . n_i
  // Real res = (_stress0[_qp] - _stress1[_qp]) * _normals[_qp] * _normals[_qp];
  RealVectorValue res = (_stress0[_qp] - _stress1[_qp]) * _normals[_qp];

  switch (type)
  {
    case Moose::Element:
      return res(_component) * _test[_i][_qp];

    case Moose::Neighbor:
      return res(_component) * _test_neighbor[_i][_qp];

    default:
      mooseError("InterfaceStress type not supported.");
  }
}

Real InterfaceStress::computeQpJacobian(Moose::DGJacobianType /*type*/) { return 0; }
