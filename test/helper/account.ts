import {
  ethers,
  deployments,
  getUnnamedAccounts,
  getNamedAccounts,
} from "hardhat";
import { accountIdentifier } from "../../identifier";

export type Keys<T> = T extends { [name in keyof T]: infer U } ? U : never;
export type MapProp<T> = {
  [P in keyof T]: string;
};

export class Account {
  private constructor() {}

  public static async get() {
    const accounts = await getNamedAccounts();

    const obj: MapProp<typeof accountIdentifier> = {
      baliola: accounts[accountIdentifier.baliola],
      deployer: accounts[accountIdentifier.deployer],
      manager: accounts[accountIdentifier.manager],
      user_1: accounts[accountIdentifier.user_1],
      user_2: accounts[accountIdentifier.user_2],
    };

    return obj;
  }
}
