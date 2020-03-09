import htmlcoin from 'htmlcoinjs-lib'
import bip39 from 'bip39'
import server from './server'
import config from './config'

const unit = ' HTML'
let network = {}
switch (config.getNetwork()) {
  case 'testnet':
    network = htmlcoin.networks.htmlcoin_testnet
    break
  case 'mainnet':
    network = htmlcoin.networks.htmlcoin
    break
}

export default class Wallet {
  constructor (keyPair, extend = {}) {
    this.keyPair = keyPair
    this.extend = extend
    this.info = {
      address: this.getAddress(),
      balance: 'loading',
      unconfirmedBalance: 'loading',
      hrc20: [],
    }
    this.txList = []
  }

  validateMnemonic (mnemonic, password) {
    const tempWallet = Wallet.restoreFromMnemonic(mnemonic, password)
    return this.keyPair.toWIF() === tempWallet.keyPair.toWIF()
  }

  getAddress () {
    return this.keyPair.getAddress()
  }

  getHasPrivKey () {
    return !!this.keyPair.d
  }

  getPrivKey () {
    try {
      return this.keyPair.toWIF()
    } catch (e) {
      if (e.toString() === 'Error: Missing private key') {
        return null
      } else {
        throw e
      }
    }
  }

  init () {
    if (config.getMode() !== 'offline') {
      this.setInfo()
      this.setHrc20()
      this.setTxList()
    }
  }

  async setInfo () {
    const info = await server.currentNode().getInfo(this.info.address)
    this.info.balance = info.balance + unit
    this.info.unconfirmedBalance = info.unconfirmedBalance + unit
  }

  async setHrc20 () {
    this.info.hrc20 = await server.currentNode().getHrc20(this.info.address)
  }

  async setTxList () {
    this.txList = await server.currentNode().getTxList(this.info.address)
  }

  async generateSendToContractTx (contractAddress, encodedData, gasLimit, gasPrice, fee, amount) {
    const utxoList = await server.currentNode().getUtxoList(this.info.address)
    return Wallet.generateSendToContractTx(this, contractAddress, encodedData, gasLimit, gasPrice, fee, utxoList, amount)
  }

  async generateTx (to, amount, fee) {
    const utxoList = await server.currentNode().getUtxoList(this.info.address)
    return Wallet.generateTx(this, to, amount, fee, utxoList)
  }

  async sendRawTx (tx) {
    const res = await Wallet.sendRawTx(tx)
    this.init()
    return res
  }

  async callContract (address, encodedData) {
    return Wallet.callContract(address, encodedData)
  }

  static async generateSendToContractTx (wallet, contractAddress, encodedData, gasLimit, gasPrice, fee, utxoList, amount) {
    return htmlcoin.utils.buildSendToContractTransaction(wallet.keyPair, contractAddress, encodedData, gasLimit, gasPrice, fee, utxoList, amount)
  }

  static async generateTx (wallet, to, amount, fee, utxoList) {
    return htmlcoin.utils.buildPubKeyHashTransaction(wallet.keyPair, to, amount, fee, utxoList)
  }

  static async sendRawTx (tx) {
    return server.currentNode().sendRawTx(tx)
  }

  static async callContract (address, encodedData) {
    return server.currentNode().callContract(address, encodedData)
  }

  static validateBip39Mnemonic (mnemonic) {
    return bip39.validateMnemonic(mnemonic)
  }

  static restoreFromMnemonic (mnemonic, password) {
    // if (bip39.validateMnemonic(mnemonic) == false) return false
    const seedHex = bip39.mnemonicToSeedHex(mnemonic, password)
    const hdNode = htmlcoin.HDNode.fromSeedHex(seedHex, network)
    const account = hdNode.deriveHardened(88).deriveHardened(0).deriveHardened(0)
    const keyPair = account.keyPair
    return new Wallet(keyPair)
  }

  static restoreFromMobile (mnemonic) {
    const seedHex = bip39.mnemonicToSeedHex(mnemonic)
    const hdNode = htmlcoin.HDNode.fromSeedHex(seedHex, network)
    const account = hdNode.deriveHardened(88).deriveHardened(0)
    const walletList = []
    for (let i = 0; i < 10; i++) {
      const wallet = new Wallet(account.deriveHardened(i).keyPair)
      wallet.setInfo()
      walletList[i] = {
        wallet,
        path: i,
      }
    }
    return walletList
  }

  static restoreFromWif (wif) {
    return new Wallet(htmlcoin.ECPair.fromWIF(wif, network))
  }

  static restoreFromHdNodeByPage (hdNode, start, length = 10) {
    const walletList = []
    const extend = hdNode.extend
    for (let i = start; i < length + start; i++) {
      const wallet = new Wallet(hdNode.derive(i).keyPair, extend)
      wallet.setInfo()
      walletList[i] = {
        wallet,
        path: i,
      }
    }
    return walletList
  }

  static generateMnemonic () {
    return bip39.generateMnemonic()
  }
}
