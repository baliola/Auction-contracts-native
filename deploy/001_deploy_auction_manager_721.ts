import { HardhatRuntimeEnvironment } from "hardhat/types";

const func = async function (hre: HardhatRuntimeEnvironment) {
  const accounts = await hre.getNamedAccounts();
};
