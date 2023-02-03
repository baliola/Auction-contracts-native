import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { contractIdentifier, accountIdentifier } from "../identifier";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const accounts = await hre.getNamedAccounts();

  const deployerAddress = accounts[accountIdentifier.deployer];
  const baliolaAddress = accounts[accountIdentifier.baliola];
  const managerAddress = accounts[accountIdentifier.manager];

  const deployer = hre.deployments;

  const contract = contractIdentifier.fixedPriceAuctionManager1155;

  await deployer.deploy(contract, {
    from: deployerAddress,
    args: [baliolaAddress, managerAddress],
    log: true,
    autoMine: true,
  });
};

export default func;
func.tags = [contractIdentifier.fixedPriceAuctionManager1155];
