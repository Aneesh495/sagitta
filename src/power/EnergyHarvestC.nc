#include "sagitta_types.h"
#include "power_params.h"

/**
 * EnergyHarvestC wires induction harvesting, supercapacitor monitoring,
 * and adaptive power budgeting modules.
 */
configuration EnergyHarvestC {
  provides {
    interface EnergyHarvest;
    interface InductionHarvest;
    interface SupercapManager;
    interface PowerBudget;
  }
}
implementation {
  components EnergyHarvestP;
  components InductionHarvestP;
  components SupercapManagerP;
  components PowerBudgetP;

  EnergyHarvest = EnergyHarvestP.EnergyHarvest;
  InductionHarvest = InductionHarvestP.InductionHarvest;
  SupercapManager = SupercapManagerP.SupercapManager;
  PowerBudget = PowerBudgetP.PowerBudget;

  EnergyHarvestP.InductionHarvest -> InductionHarvestP.InductionHarvest;
  EnergyHarvestP.SupercapManager -> SupercapManagerP.SupercapManager;
  EnergyHarvestP.PowerBudget -> PowerBudgetP.PowerBudget;
}
