<template>
  <section>
    <v-toolbar flat>
      <v-btn
        icon
        to="/"
      >
        <v-icon>mdi-chevron-left</v-icon>
      </v-btn>
      <v-divider
        class="mx-3"
        inset
        vertical
      />
      Buy Tickets
    </v-toolbar>
    <v-divider />
    <div class="text-center pa-3">
      <div class="mb-3">
        Current Ticket Price
        <v-btn
          color="blue-grey"
          icon
          x-small
          dark
          @click="priceInfo=true"
        >
          <v-icon>mdi-information</v-icon>
        </v-btn>
      </div>
      <div
        v-if="loadingTicketPrice"
        class="pa-5 headline"
      >
        <v-progress-circular
          indeterminate
          color="green"
        />
      </div>
      <div
        v-else
        class="pa-5 headline"
      >
        <b>$5 USD = {{ parseFloat(ticketPrice).toLocaleString("en-US", {style: "decimal", minimumFractionDigits: 2}) }} HTML</b>
      </div>
      <div>
        <p>
          Lottochain tickets are indexed by USD and paid with
          <a
            href="https://htmlcoin.com"
            target="_blank"
          >
            <b>HTMLCOIN</b>
          </a>.
        </p>
      </div>
      <v-divider />
      <div
        v-if="loadingLotteryStatus"
        class="pa-5 headline"
      >
        <v-progress-circular
          :size="70"
          :width="7"
          indeterminate
          color="green"
        />
      </div>
      <div
        v-else-if="!wallet"
        class="pa-5 text-center subheading"
      >
        <div class="pa-3 body-2">
          If you do not have an HTMLCoin wallet yet, you can create one here, and later transfer funds to it so you can play.
          <br>
          If you already have an HTMLCoin wallet, you can import it using its private key, and use its funds to play.
        </div>
        <div class="pa-3">
          <v-btn
            :disabled="!lotteryActive"
            x-large
            color="light-green darken-2"
            @click.once="create"
          >
            <v-icon
              left
              dark
            >
              mdi-new-box
            </v-icon>
            Create HTMLCOIN Wallet
          </v-btn>
        </div>
        <div class="pa-3">
          <v-btn
            :disabled="!lotteryActive"
            x-large
            color="green darken-4"
            @click="importWallet=true"
          >
            <v-icon
              left
              dark
            >
              mdi-wallet
            </v-icon>
            Import HTMLCOIN Wallet
          </v-btn>
        </div>
      </div>
      <div
        v-else
        class="subheading"
      >
        <template v-if="loadingWalletData">
          <v-row class="pt-5">
            <v-spacer />
            <div>
              <v-progress-circular
                :size="70"
                :width="7"
                indeterminate
                color="green"
              />
            </div>
            <v-spacer />
          </v-row>
        </template>
        <template v-else>
          <v-row>
            <v-col>
              <v-spacer />
              <div>
                Your wallet address: <b>{{ walletAddress }}</b>
                <v-btn
                  color="blue-grey"
                  icon
                  x-small
                  dark
                  @click="pkDialog=true"
                >
                  <v-icon>mdi-lock</v-icon>
                </v-btn>
              </div>
              <v-spacer />
            </v-col>
          </v-row>
          <v-row>
            <v-col>
              <v-spacer />
              <div class="pb-3 subtitle-1">
                Your funds: <b>{{ parseFloat(wallet.info['balance']).toLocaleString("en-US", {style: "decimal", minimumFractionDigits: 8}) }} HTML</b>
                <v-btn
                  x-small
                  icon
                  @click="refreshWallet"
                >
                  <v-icon color="info">
                    mdi-refresh
                  </v-icon>
                </v-btn>
                <v-spacer />
              </div>
              <div class="pb-3 caption">
                <v-btn
                  href="https://htmlbunker.com/trading/htmlbtc"
                  target="_blank"
                  x-small
                  color="success"
                >
                  PURCHASE HTMLCOIN
                </v-btn>
              </div>
            </v-col>
          </v-row>
          <v-divider />
          <v-row>
            <v-col>
              <v-spacer />
              <span class="subtitle-1">Your valid tickets:</span>
              <v-spacer />
            </v-col>
          </v-row>
          <v-row>
            <v-col cols="3">
              Daily
              <br>
              <b>{{ currentBalanceDailyTickets }} ticket<span v-if="currentBalanceDailyTickets > 1">s</span></b>
            </v-col>
            <v-col cols="3">
              Weekly
              <br>
              <b>{{ currentBalanceWeeklyTickets }} ticket<span v-if="currentBalanceWeeklyTickets > 1">s</span></b>
            </v-col>
            <v-col cols="3">
              Monthly
              <br>
              <b>{{ currentBalanceMonthlyTickets }} ticket<span v-if="currentBalanceMonthlyTickets > 1">s</span></b>
            </v-col>
            <v-col cols="3">
              Super Ticket
              <br>
              <b>{{ currentBalanceSuperTickets }} LOTTO Token<span v-if="currentBalanceSuperTickets > 1">s</span></b>
            </v-col>
          </v-row>
          <v-divider />
          <v-row>
            <v-col />
            <v-col>
              <v-select
                v-model="amount"
                :items="amounts"
                prepend-inner-icon="mdi-ticket"
                label="Buy Tickets"
                color="blue-grey darken-2"
                flat
                solo
                @change="calculateFinalPrice"
              />
            </v-col>
            <v-col />
          </v-row>
          <div v-if="parseInt(finalPrice) > 0">
            <div class="pa-5 headline">
              <b>Final price: {{ finalPrice }} HTML</b>
              <v-btn
                color="blue-grey"
                icon
                x-small
                dark
                @click="finalPriceInfo=true"
              >
                <v-icon>mdi-information</v-icon>
              </v-btn>
            </div>
            <div class="pa-5">
              <v-btn
                color="green darken-4"
                @click="confirmBuy = true"
              >
                Buy Tickets!
              </v-btn>
            </div>
          </div>
        </template>
      </div>
    </div>
    <v-dialog
      v-model="importWallet"
      width="600px"
    >
      <v-card color="blue-grey darken-3">
        <v-card-title
          class="justify-center"
          primary-title
        >
          <div>
            <div class="headline font-weight-medium white--text">
              <v-icon large>
                mdi-wallet
              </v-icon>
              IMPORT HTMLCOIN WALLET
            </div>
          </div>
        </v-card-title>
        <v-card-text>
          <v-row>
            <v-col>
              <v-text-field
                v-model.trim="wif"
                label="Private Key"
                outlined
                @keydown.enter="restore"
              />
            </v-col>
          </v-row>
        </v-card-text>
        <v-card-actions>
          <v-spacer />
          <v-btn
            color="success"
            @click="restore"
          >
            confirm
          </v-btn>
          <v-spacer />
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-dialog
      v-model="newWallet"
      width="600px"
    >
      <div v-if="loadingNewWallet">
        <v-spacer />
        <v-progress-circular
          indeterminate
          color="blue"
        />
        <v-spacer />
      </div>
      <v-card
        v-else
        color="blue-grey darken-3"
      >
        <v-card-title
          class="justify-center"
          primary-title
        >
          <div>
            <div class="headline font-weight-medium white--text">
              <v-icon large>
                mdi-wallet
              </v-icon>
              NEW HTMLCOIN WALLET
            </div>
          </div>
        </v-card-title>
        <v-card-text>
          <v-row justify="center">
            <center>
              Your new wallet has been created.
              <br>
              <b>
                <span class="red--text">Please copy its private key for future use.</span>
              </b>
            </center>
          </v-row>
          <v-row class="pt-5">
            <v-text-field
              v-model.trim="walletAddress"
              label="Wallet Address"
              outlined
            />
          </v-row>
          <v-row>
            <v-text-field
              ref="privateKey"
              v-model.trim="privateKey"
              label="Private Key"
              outlined
            />
          </v-row>
          <v-row v-if="!copySuccess">
            <v-btn
              block
              color="info"
              @click="copyPK"
            >
              Copy private key
            </v-btn>
          </v-row>
          <v-row
            v-else
            justify="center"
          >
            <b>Private key copied to clipboard! Please paste it somewhere safe.</b>
          </v-row>
        </v-card-text>
        <v-card-actions>
          <v-spacer />
          <v-btn
            color="blue-grey"
            @click="newWallet = false"
          >
            close
          </v-btn>
          <v-spacer />
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-dialog
      v-model="pkDialog"
      width="600px"
    >
      <v-card
        color="blue-grey darken-3"
      >
        <v-card-title
          class="justify-center"
          primary-title
        >
          <div>
            <div class="headline font-weight-medium white--text">
              <v-icon large>
                mdi-lock-outline
              </v-icon>
              PRIVATE KEY
            </div>
          </div>
        </v-card-title>
        <v-card-text>
          <v-row>
            <v-text-field
              ref="privateKey"
              v-model.trim="privateKey"
              label="Private Key"
              outlined
            />
          </v-row>
          <v-row v-if="!copySuccess">
            <v-btn
              block
              color="info"
              @click="copyPK"
            >
              Copy private key
            </v-btn>
          </v-row>
          <v-row
            v-else
            justify="center"
          >
            <b>Private key copied to clipboard! Please paste it somewhere safe.</b>
          </v-row>
        </v-card-text>
        <v-card-actions>
          <v-spacer />
          <v-btn
            color="error"
            @click="pkDialog = false"
          >
            close
          </v-btn>
          <v-spacer />
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-dialog
      v-model="priceInfo"
      width="600px"
    >
      <v-card
        class="pa-5"
        color="blue-grey darken-3"
      >
        The USD/HTML rate is set based on the average price and market volume, and it may be sometimes a little bit different from your prefered exchange. After fast dump and pump on rates, there might be a delay for it to get updated on our system. The ticket price will always respect the rate shown here, and not the market price.
      </v-card>
    </v-dialog>
    <v-dialog
      v-model="finalPriceInfo"
      width="600px"
    >
      <v-card
        class="pa-5"
        color="blue-grey darken-3"
      >
        2 HTML were added to the value for the network fees (transaction gas + mining fee). A part of this amount will be reimbursed after the transaction is completed.
      </v-card>
    </v-dialog>
    <v-dialog
      v-model="disabledLotteryDialog"
      width="600px"
    >
      <v-card
        class="pa-5"
        color="blue-grey darken-3"
      >
        <center>
          <p class="title">
            Lottochain has been paused.
          </p>
          <p>
            This status happens during drawing or maintenance times.
            <br>
            Please try again soon.
          </p>
        </center>
      </v-card>
    </v-dialog>
    <v-dialog
      v-model="priceChangedDialog"
      width="600px"
    >
      <v-card
        class="pa-5"
        color="blue-grey darken-3"
      >
        <center>
          <p class="title">
            The ticket price has been updated.
          </p>
          <p>
            Please select your ticket quantity again and check for new values.
          </p>
        </center>
      </v-card>
    </v-dialog>
    <v-dialog
      v-model="confirmBuy"
      width="600px"
    >
      <v-card
        class="pa-5"
        color="blue-grey darken-4"
      >
        <span
          v-if="amount < 2"
          class="pa-5 title"
        >
          <center>
            Do you confirm the purchase of <br>{{ amount }} ticket for {{ finalPrice }} HTML ?
          </center>
        </span>
        <span
          v-else
          class="pa-5 title"
        >
          <center>
            Do you confirm the purchase of <br>{{ amount }} tickets for {{ finalPrice }} HTML ?
          </center>
        </span>
        <v-card-actions>
          <v-spacer />
          <v-btn
            color="blue-grey"
            @click="confirmBuy = false"
          >
            cancel
          </v-btn>
          <v-spacer />
          <v-btn
            color="success"
            @click="buyTickets"
          >
            confirm
          </v-btn>
          <v-spacer />
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-dialog
      v-model="txConfirmation"
      width="600px"
      persistent
    >
      <v-card
        class="pa-5"
        color="blue-grey darken-3"
      >
        <div v-if="awaitingTx">
          <v-row>
            <v-col>
              <center>
                <span class="pa-3 title blue--text">
                  Transaction broadcasted to the <b>Althash Blockchain</b>!
                </span>
              </center>
            </v-col>
          </v-row>
          <v-row>
            <v-col>
              <center>
                <span class="pa-3 white--text">
                  Awaiting confirmation from the network...
                </span>
              </center>
            </v-col>
          </v-row>
          <v-row>
            <v-col>
              <span class="pa-3">
                <v-progress-linear
                  :indeterminate="true"
                  color="green darken-4"
                />
              </span>
            </v-col>
          </v-row>
          <v-row>
            <v-col>
              <center>
                <span class="pa-3 caption white--text">
                  Transaction ID: {{ txId }}
                  <v-btn
                    icon
                    x-small
                    :href="txViewUrl"
                    target="_blank"
                    color="blue-grey"
                  >
                    <v-icon>
                      mdi-search-web
                    </v-icon>
                  </v-btn>
                </span>
              </center>
            </v-col>
          </v-row>
        </div>
        <div v-else-if="txSuccess">
          <v-row>
            <v-col>
              <center>
                <span class="pa-3 text-center title green--text">
                  Purchase completed!
                </span>
              </center>
            </v-col>
          </v-row>
          <v-row>
            <v-col>
              <center>
                <span class="pa-3 white--text">
                  <p>
                    Your tickets have been purchased.
                    <br>
                    You are now participating on the next daily, weekly and monthly draws.
                  </p>
                  <p>
                    <b>Good luck!</b>
                  </p>
                </span>
              </center>
            </v-col>
          </v-row>
          <v-row>
            <v-col>
              <center>
                <v-btn
                  color="error"
                  @click="closeTxConfirmation"
                >
                  close
                </v-btn>
              </center>
            </v-col>
          </v-row>
        </div>
        <div v-else-if="txError">
          <v-row>
            <v-col>
              <center>
                <span class="pa-3 title red--text">
                  Purchase unsuccessful!
                </span>
              </center>
            </v-col>
          </v-row>
          <v-row>
            <v-col>
              <center>
                <span class="pa-3 white--text">
                  <p>
                    An error has occurred in your transaction.
                    <br>
                    The values have not been charged from your wallet.
                  </p>
                </span>
              </center>
            </v-col>
          </v-row>
          <v-row>
            <v-col>
              <center>
                <v-btn
                  color="error"
                  @click="closeTxConfirmation"
                >
                  close
                </v-btn>
              </center>
            </v-col>
          </v-row>
        </div>
      </v-card>
    </v-dialog>
  </section>
</template>
<script>
  import webWallet from '../../libs/web-wallet'
  import config from '../../libs/config'
  import server from '../../libs/server'
  import axios from 'axios'
  import abi from 'ethjs-abi'
  import base58 from 'bs58'

  const contractAddress = config.getNetwork() === 'mainnet' ? 'ced6ccc8eead0970c8f178062779d5c547a53de7' : 'ac84457145f4e0330629a3f58032305fbfaa2854'

  const abiJson = JSON.parse(
    '[{"constant": true, "inputs": [], "name": "dailyPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "ticketPrice", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [{"name": "", "type": "uint256"} ], "name": "weeklyTickets", "outputs": [{"name": "", "type": "address"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "accumulatedWeeklyPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "accumulatedDailyPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "weeklyPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [{"name": "_address", "type": "address"} ], "name": "getAddressCurrentTicketQty", "outputs": [{"name": "dailyTicketsBalance", "type": "uint256"}, {"name": "weeklyTicketsBalance", "type": "uint256"}, {"name": "monthlyTicketsBalance", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "accumulatedSuperTicketsPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "superTicketsPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "superTicketPrice", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "accumulatedMonthlyPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [{"name": "", "type": "uint256"} ], "name": "monthlyTickets", "outputs": [{"name": "", "type": "address"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [{"name": "", "type": "uint256"} ], "name": "dailyTickets", "outputs": [{"name": "", "type": "address"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "lotteryActive", "outputs": [{"name": "", "type": "bool"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "monthlyPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [{"name": "_drawDate", "type": "uint256"}, {"name": "_drawType", "type": "uint8"} ], "name": "drawsHistory", "outputs": [{"name": "hashDraw1", "type": "bytes32"}, {"name": "hashDraw2", "type": "bytes32"}, {"name": "drawnAddress", "type": "address"}, {"name": "blockNumber", "type": "uint256"}, {"name": "prize", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": false, "inputs": [], "name": "buyTicket", "outputs": [], "payable": true, "stateMutability": "payable", "type": "function"} ]',
  )

  // const superTicketContractAddress = config.getNetwork() === 'mainnet' ? '0' : 'dc7d90f8bcab33cb1d855c07f3a2b7a7529cd92a'

  export default {
    data () {
      return {
        priceChangedDialog: false,
        loadingWalletData: true,
        currentBalanceDailyTickets: 0,
        currentBalanceWeeklyTickets: 0,
        currentBalanceMonthlyTickets: 0,
        currentBalanceSuperTickets: 0,
        disabledLotteryDialog: false,
        loadingLotteryStatus: true,
        lotteryActive: true,
        pkDialog: false,
        loadingNewWallet: false,
        copySuccess: false,
        copyError: false,
        ticketPrice: 0,
        loadingTicketPrice: true,
        confirmBuy: false,
        priceInfo: false,
        finalPriceInfo: false,
        privateKey: '',
        newWallet: false,
        walletAddress: '',
        wallet: false,
        importWallet: false,
        walletBalance: 0,
        amount: 0,
        amounts: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30],
        finalPrice: 0,
        transactionPrice: 0,
        wif: '',
        txId: '',
        txViewUrl: '',
        awaitingTx: false,
        txConfirmation: false,
        txSuccess: false,
        txError: false,
        gasPrice: '40',
        gasLimit: '5000000',
        fee: '0.01',
      }
    },
    mounted () {
      this.getInfo()
    },
    methods: {
      copyPK () {
        var self = this
        const pkToCopy = self.$refs.privateKey.$el.querySelector('input')
        pkToCopy.select()
        document.execCommand('copy')
        self.copySuccess = true
      },
      async restore () {
        var self = this
        self.loadingWalletData = true
        try {
          await webWallet.restoreFromWif(self.wif)
          await this.setWallet()
          await this.getCurrentTicketsBalance()
        } catch (e) {
          console.log('restore_wif_restore_error: ' + e.stack || e.toString() || e)
          alert(e.toString())
          return false
        }
        self.importWallet = false
        self.loadingWalletData = false
      },
      async create () {
        var self = this
        self.loadingWalletData = true
        self.loadingNewWallet = true
        self.newWallet = true
        try {
          const mnemonic = webWallet.generateMnemonic()
          const password = Date.now()

          webWallet.restoreFromMnemonic(mnemonic, password)
          await this.setWallet()
          self.privateKey = self.wallet.getPrivKey()
          self.loadingNewWallet = false
          self.loadingWalletData = false
        } catch (e) {
          console.log('create_wallet_error: ' + e.stack || e.toString() || e)
          return false
        }
      },
      async setWallet () {
        var self = this
        self.wallet = webWallet.getWallet()
        self.wallet.init()
        self.walletAddress = self.wallet.info.address
        self.privateKey = self.wallet.getPrivKey()
      },
      async getCurrentTicketsBalance () {
        var self = this
        const hexAddress = '0x' + base58.decode(self.walletAddress).toString('hex').substr(2, 40)
        try {
          var decodedResult = await this.callContractFunction(
            contractAddress,
            abiJson,
            'getAddressCurrentTicketQty',
            [hexAddress],
          )
          self.currentBalanceDailyTickets = parseInt(decodedResult[0])
          self.currentBalanceWeeklyTickets = parseInt(decodedResult[1])
          self.currentBalanceMonthlyTickets = parseInt(decodedResult[2])
          /*
          for (var i = 0; i < self.wallet.info.hrc20.length; i++) {
            if (self.wallet.info.hrc20[i].contract.contract_address === superTicketContractAddress) {
              self.currentBalanceSuperTickets = parseInt(self.wallet.info.hrc20[i].amount)
              break
            }
          }
          */
        } catch (e) {
          console.log('Error reading tickets balance: ' + e.stack || e.toString() || e)
          alert(e.message || e)
        }
      },
      calculateFinalPrice () {
        var self = this
        self.transactionPrice = parseFloat(self.amount) * parseFloat(self.ticketPrice)
        if (parseFloat(self.transactionPrice + 2) > parseFloat(self.wallet.info.balance)) {
          alert('The final price is greater than your wallet balance!')
          self.amount = ''
          self.finalPrice = 0
        } else {
          self.finalPrice = (self.transactionPrice + 2).toLocaleString('en-US', { style: 'decimal', minimumFractionDigits: 2 })
        }
      },
      async refreshWallet () {
        var self = this
        self.wallet.setInfo()
      },
      async buyTickets () {
        var self = this
        const checkPrice = self.ticketPrice
        self.confirmBuy = false
        await this.getInfo()
        if (checkPrice !== self.ticketPrice) {
          self.finalPrice = 0
          self.amount = 0
          self.priceChangedDialog = true
        } else {
          self.txConfirmation = true
          self.awaitingTx = true

          try {
            const encodedData = this.encodeContractSendFunction(
              abiJson,
              'buyTicket',
              [],
            )
            const rawTx = await self.wallet.generateSendToContractTx(
              contractAddress,
              encodedData,
              self.gasLimit,
              self.gasPrice,
              self.fee,
              self.transactionPrice,
            )

            self.txId = await self.wallet.sendRawTx(rawTx)
            self.txViewUrl = server.currentNode().getTxExplorerUrl(self.txId)

            var apiURL = config.getNetwork() === 'mainnet' ? 'https://explorer.htmlcoin.com/api/tx/' : 'https://testnet.htmlcoin.com/api/tx/'

            const interval = setInterval(() => {
              axios.get(apiURL + self.txId).then(result => {
                console.log('Checking Tx...')

                if (result.data.confirmations > 0) {
                  clearInterval(interval)
                  self.awaitingTx = false

                  if (result.data.receipt[0].excepted !== 'None') {
                    self.txError = true
                  } else {
                    self.txSuccess = true
                  }
                }
              }).catch(console.error)
            }, 15 * 1000)
          } catch (e) {
            console.log('Error: ' + e.stack || e.toString() || e)
            alert('Transaction error!')
            self.awaitingTx = false
            return false
          }
        }
      },
      async getInfo () {
        var self = this
        self.loadingTicketPrice = true
        try {
          var decodedResult = await this.callContractFunction(
            contractAddress,
            abiJson,
            'ticketPrice',
            [],
          )
          self.ticketPrice = parseInt(decodedResult[0]) / 100000000
          self.loadingTicketPrice = false

          decodedResult = await this.callContractFunction(
            contractAddress,
            abiJson,
            'lotteryActive',
            [],
          )
          self.lotteryActive = decodedResult[0]
          if (!self.lotteryActive) {
            self.disabledLotteryDialog = true
            self.wallet = false
          }
          self.loadingLotteryStatus = false
        } catch (e) {
          console.log('Error reading ticket price: ' + e.stack || e.toString() || e)
          alert(e.message || e)
        }
      },
      closeTxConfirmation () {
        var self = this
        self.txConfirmation = false
        self.loadingTicketPrice = true
        this.getInfo()
        this.refreshWallet()
        this.getCurrentTicketsBalance()
      },
      findIndexByName (abiJson, name) {
        return abiJson.findIndex(function (item) {
          return item.name === name
        })
      },
      async callContractFunction (contractAddress, abiJson, functionName, params) {
        const encodedData = abi.encodeMethod(
          abiJson[
            this.findIndexByName(
              abiJson,
              functionName,
            )
          ],
          params,
        ).substr(2)
        var encodedResult = await server.currentNode().callContract(contractAddress, encodedData)
        encodedResult = '0x' + encodedResult

        return abi.decodeMethod(abiJson[this.findIndexByName(abiJson, functionName)], encodedResult)
      },
      encodeContractSendFunction (abiJson, functionName, params) {
        return abi.encodeMethod(
          abiJson[this.findIndexByName(abiJson, functionName)],
          params,
        ).substr(2)
      },
    },
  }
</script>
