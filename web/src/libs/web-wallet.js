import Wallet from './wallet'

let wallet = false

function getWallet () {
  return wallet
}

function setWallet (wal) {
  wallet = wal
}

function generateMnemonic () {
  return Wallet.generateMnemonic()
}

function restoreFromMnemonic (mnemonic, password) {
  return (wallet = Wallet.restoreFromMnemonic(mnemonic, password))
}

function restoreFromMobile (mnemonic) {
  return Wallet.restoreFromMobile(mnemonic)
}

function chooseMobileWallet (walletList, path) {
  return (wallet = walletList[path].wallet)
}

function restoreFromWif (wif) {
  return (wallet = Wallet.restoreFromWif(wif))
}

function restoreFromHdNodeByPage (hdNode, start, length = 10) {
  return Wallet.restoreFromHdNodeByPage(hdNode, start, length)
}

function validateBip39Mnemonic (mnemonic) {
  return Wallet.validateBip39Mnemonic(mnemonic)
}

export default {
  getWallet,
  setWallet,
  generateMnemonic,
  restoreFromMnemonic,
  restoreFromMobile,
  restoreFromWif,
  restoreFromHdNodeByPage,
  chooseMobileWallet,
  validateBip39Mnemonic,
}
