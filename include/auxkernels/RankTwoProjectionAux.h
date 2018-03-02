/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#ifndef RANKTWOPROJECTIONAUX_H
#define RANKTWOPROJECTIONAUX_H

#include "AuxKernel.h"
#include "RankTwoTensor.h"

class RankTwoProjectionAux;

template <>
InputParameters validParams<RankTwoProjectionAux>();

class RankTwoProjectionAux : public AuxKernel
{
public:
  RankTwoProjectionAux(const InputParameters & parameters);

protected:
  virtual Real computeValue();

  const MaterialProperty<RankTwoTensor> & _tensor;
  bool _normal;

private:
  Real _angle;
};

#endif // RANKTWOPROJECTIONAUX_H