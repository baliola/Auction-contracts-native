const creator = 0;
const baliola = 1;
const manager = 2;

function getBaliolaWallet(accounts: string[]) {
  const _accounts = structuredClone(accounts);

  return _accounts[baliola];
}

function getCreatorWallet(accounts: string[]) {
  const _accounts = structuredClone(accounts);

  return _accounts[creator];
}

function getUsersWallet(accounts: string[]) {
  const _accounts = structuredClone(accounts);

  _accounts.shift();
  _accounts.shift();

  return _accounts;
}

function getAuctionManagerManagerAccounts(accounts: string[]) {
  const _accounts = structuredClone(accounts);

  return _accounts[manager];
}

module.exports = {
  getBaliolaWallet,
  getCreatorWallet,
  getUsersWallet,
  getAuctionManagerManagerAccounts,
};
