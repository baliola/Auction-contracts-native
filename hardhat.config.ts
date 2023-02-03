import { HardhatUserConfig } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";
import "@nomiclabs/hardhat-ethers";
import "@typechain/hardhat";

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  namedAccounts: {
    deployer: {
      default: 0,
      0: "0x017756fa7088857b4d05114905Ab9D68840D44DD",
    },
    manager: {
      default: 0,
      0: "0x31061D7Ea49ba04791cB41172F6780db12534C4a",
    },
    user_1: {
      default: 0,
      0: "0x84b372c23153C86cC37b3eece13E437b360aE37D",
    },
    user_2: {
      default: 0,
      0: "0xAe77f889c8aF6536FCf80Ba674Adc4C2aB0C3070",
    },
  },
};

export default config;
