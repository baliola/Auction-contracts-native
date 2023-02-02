module.exports = (artifacts: Truffle.Artifacts) => {
  return async (
    deployer: Truffle.Deployer,
    network: string,
    accounts: string[]
  ) => {
    await ContractDeployer.deployManager1155(deployer, network, accounts);
  };
};
