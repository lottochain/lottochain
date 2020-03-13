<template>
  <div>
    <v-navigation-drawer
      v-model="prizesDrawer"
      app
      class="black overflow-visible"
      right
      width="325"
      static
      style="overflow: visible"
    >
      <v-row
        class="mx-0 flex-column fill-height"
        justify="center"
      >
        <v-col>
          <v-list
            class="py-0"
            color="transparent"
            two-line
          >
            <v-list-item>
              <v-list-item-title class="title font-weight-bold pl-4">
                PRIZE$
              </v-list-item-title>
            </v-list-item>
            <v-divider />
            <template v-if="loadingPrizes">
              <v-row>
                <v-col />
                <v-col>
                  <v-progress-circular
                    :size="70"
                    :width="7"
                    indeterminate
                    color="amber"
                  />
                </v-col>
                <v-col />
              </v-row>
            </template>
            <template v-else-if="lotteryActive">
              <v-list-item>
                <v-list-item-action class="justify-center">
                  <v-icon color="light-green darken-3">
                    mdi-trophy
                  </v-icon>
                </v-list-item-action>
                <v-list-item-content>
                  <v-list-item-title>
                    <span class="font-weight-bold">Daily</span> • <span class="caption">{{ dailyCounterHours }}h {{ dailyCounterMinutes }}m {{ dailyCounterSeconds }}s</span>
                  </v-list-item-title>

                  <v-list-item-subtitle>
                    {{ (Math.round(dailyPrize * 100) / 100).toLocaleString("en-US", {style: "decimal", minimumFractionDigits: 0}) }} HTML ({{ dailyPrizeUSD }} USD)
                  </v-list-item-subtitle>
                </v-list-item-content>
              </v-list-item>
              <v-list-item>
                <v-list-item-action class="justify-center">
                  <v-icon color="light-green darken-3">
                    mdi-trophy
                  </v-icon>
                </v-list-item-action>
                <v-list-item-content>
                  <v-list-item-title>
                    <span class="font-weight-bold">Weekly</span> • <span class="caption">{{ weeklyCounterDays }}d {{ weeklyCounterHours }}h {{ weeklyCounterMinutes }}m {{ weeklyCounterSeconds }}s</span>
                  </v-list-item-title>

                  <v-list-item-subtitle>
                    {{ (Math.round(weeklyPrize * 100) / 100).toLocaleString("en-US", {style: "decimal", minimumFractionDigits: 0}) }} HTML ({{ weeklyPrizeUSD }} USD)
                  </v-list-item-subtitle>
                </v-list-item-content>
              </v-list-item>
              <v-list-item>
                <v-list-item-action class="justify-center">
                  <v-icon color="light-green darken-3">
                    mdi-trophy
                  </v-icon>
                </v-list-item-action>
                <v-list-item-content>
                  <v-list-item-title>
                    <span class="font-weight-bold">Monthly</span> • <span class="caption">{{ monthlyCounterDays }}d {{ monthlyCounterHours }}h {{ monthlyCounterMinutes }}m {{ monthlyCounterSeconds }}s</span>
                  </v-list-item-title>

                  <v-list-item-subtitle>
                    {{ (Math.round(monthlyPrize * 100) / 100).toLocaleString("en-US", {style: "decimal", minimumFractionDigits: 0}) }} HTML ({{ monthlyPrizeUSD }} USD)
                  </v-list-item-subtitle>
                </v-list-item-content>
              </v-list-item>
              <v-list-item>
                <v-list-item-action class="justify-center">
                  <v-icon color="amber lighten-1">
                    mdi-trophy-variant
                  </v-icon>
                </v-list-item-action>
                <v-list-item-content>
                  <v-list-item-title>
                    <span class="font-weight-bold">Super Ticket</span> • <span class="caption">{{ monthlyCounterDays }}d {{ monthlyCounterHours }}h {{ monthlyCounterMinutes }}m {{ monthlyCounterSeconds }}s</span>
                  </v-list-item-title>

                  <v-list-item-subtitle>
                    {{ (Math.round(superTicketsPrize * 100) / 100).toLocaleString("en-US", {style: "decimal", minimumFractionDigits: 0}) }} HTML ({{ superTicketsPrizeUSD }} USD)
                  </v-list-item-subtitle>
                </v-list-item-content>
              </v-list-item>
            </template>
            <template v-else>
              <v-row>
                <v-col>
                  <center>
                    <v-progress-circular
                      :size="50"
                      :width="7"
                      indeterminate
                      color="lime"
                    />
                  </center>
                </v-col>
              </v-row>
              <v-row>
                <v-col>
                  <span class="mx-5 subtitle-1">
                    <center>
                      <p>
                        <b>
                          Drawing Prizes... Please wait!
                        </b>
                      </p>
                    </center>
                  </span>
                </v-col>
              </v-row>
              <v-row>
                <v-col>
                  <span class="caption">
                    <p class="mx-5 text-justify">
                      Lottochain prizes are drawn based on the first HTMLCoin and Bitcoin blocks added to their respective blockchains after <b>1 AM GMT</b>.
                    </p>
                    <p class="mx-5 text-justify">
                      The ideal number of confirmations on Bitcoin's Blockchain is 6. In other words, for a Bitcoin block to be considered "irreversible", it needs 6 blocks to be added after it.
                    </p>
                    <p class="mx-5 text-justify">
                      Since the average time between Bitcoin blocks is 10 minutes, the time between the selected block and its confirmation is around <b>1 hour</b>.
                    </p>
                    <p class="mx-5 text-justify">
                      Therefore, every day at 1 AM GMT Lottochain will be paused for around 1 hour, until the draws are executed.
                    </p>
                  </span>
                </v-col>
              </v-row>
            </template>
          </v-list>
        </v-col>
      </v-row>
    </v-navigation-drawer>

    <core-fab />
  </div>
</template>

<script>
  import config from '../../libs/config'
  import server from '../../libs/server'
  import abi from 'ethjs-abi'

  import {
    mapMutations,
    mapState,
  } from 'vuex'

  const contractAddress = config.getNetwork() === 'mainnet' ? 'ced6ccc8eead0970c8f178062779d5c547a53de7' : 'ac84457145f4e0330629a3f58032305fbfaa2854'

  const abiJson = JSON.parse(
    '[{"constant": true, "inputs": [], "name": "dailyPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "ticketPrice", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [{"name": "", "type": "uint256"} ], "name": "weeklyTickets", "outputs": [{"name": "", "type": "address"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "accumulatedWeeklyPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "accumulatedDailyPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "weeklyPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [{"name": "_address", "type": "address"} ], "name": "getAddressCurrentTicketQty", "outputs": [{"name": "dailyTicketsBalance", "type": "uint256"}, {"name": "weeklyTicketsBalance", "type": "uint256"}, {"name": "monthlyTicketsBalance", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "accumulatedSuperTicketsPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "superTicketsPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "superTicketPrice", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "accumulatedMonthlyPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [{"name": "", "type": "uint256"} ], "name": "monthlyTickets", "outputs": [{"name": "", "type": "address"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [{"name": "", "type": "uint256"} ], "name": "dailyTickets", "outputs": [{"name": "", "type": "address"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "lotteryActive", "outputs": [{"name": "", "type": "bool"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "monthlyPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [{"name": "_drawDate", "type": "uint256"}, {"name": "_drawType", "type": "uint8"} ], "name": "drawsHistory", "outputs": [{"name": "hashDraw1", "type": "bytes32"}, {"name": "hashDraw2", "type": "bytes32"}, {"name": "drawnAddress", "type": "address"}, {"name": "blockNumber", "type": "uint256"}, {"name": "prize", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": false, "inputs": [], "name": "buyTicket", "outputs": [], "payable": true, "stateMutability": "payable", "type": "function"} ]',
  )

  export default {
    name: 'CorePrizes',

    components: {
      CoreFab: () => import('./Fab'),
    },

    data () {
      return {
        ticketPrice: 0,
        loadingPrizes: true,
        dailyPrize: 0,
        dailyPrizeUSD: 0,
        weeklyPrize: 0,
        weeklyPrizeUSD: 0,
        monthlyPrize: 0,
        monthlyPrizeUSD: 0,
        superTicketsPrize: 0,
        superTicketsPrizeUSD: 0,
        dailyCounterHours: 0,
        dailyCounterMinutes: 0,
        dailyCounterSeconds: 0,
        weeklyCounterDays: 0,
        weeklyCounterHours: 0,
        weeklyCounterMinutes: 0,
        weeklyCounterSeconds: 0,
        monthlyCounterDays: 0,
        monthlyCounterHours: 0,
        monthlyCounterMinutes: 0,
        monthlyCounterSeconds: 0,
      }
    },

    computed: {
      ...mapState('prizes', [
        'drawer',
        'prizes',
      ]),
      prizesDrawer: {
        get () {
          return this.drawer
        },
        set (val) {
          this.setDrawer(val)
        },
      },
    },

    async mounted () {
      this.counterDaily()
      this.counterWeekly()
      this.counterMonthly()
      await this.getTicketPrice()
      await this.getPrizes()
    },

    methods: {
      ...mapMutations('prizes', ['setDrawer']),
      async getTicketPrice () {
        var self = this
        try {
          var decodedResult = await this.callContractFunction(
            contractAddress,
            abiJson,
            'ticketPrice',
            [],
          )
          self.ticketPrice = parseInt(decodedResult[0]) / 100000000
          self.loadingTicketPrice = false
        } catch (e) {
          console.log('Error reading ticket price: ' + e.stack || e.toString() || e)
          alert(e.message || e)
        }
      },
      counterDaily () {
        var self = this
        var d = new Date()
        var prizeDate = new Date(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate(), d.getUTCHours(), d.getUTCMinutes(), d.getUTCSeconds(), d.getUTCMilliseconds())

        if (prizeDate.getHours() >= 1) {
          prizeDate.setDate(prizeDate.getDate() + 1)
        }

        prizeDate.setHours(1)
        prizeDate.setMinutes(0)
        prizeDate.setSeconds(0)
        prizeDate.setMilliseconds(0)

        var countDownTime = prizeDate.getTime()
        var nowGMTTime
        var distance

        var x = setInterval(function () {
          d = new Date()
          nowGMTTime = new Date(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate(), d.getUTCHours(), d.getUTCMinutes(), d.getUTCSeconds(), d.getUTCMilliseconds()).getTime()
          distance = countDownTime - nowGMTTime

          self.dailyCounterHours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
          self.dailyCounterMinutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60))
          self.dailyCounterSeconds = Math.floor((distance % (1000 * 60)) / 1000)

          if (distance < 0) {
            clearInterval(x)
            self.dailyCounterHours = 0
            self.dailyCounterMinutes = 0
            self.dailyCounterSeconds = 0
          }
        }, 1000)
      },
      counterWeekly () {
        var self = this
        var d = new Date()
        var baseDate = new Date(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate(), d.getUTCHours(), d.getUTCMinutes(), d.getUTCSeconds(), d.getUTCMilliseconds())

        if (baseDate.getDay() === 6 && baseDate.getHours() >= 1) {
          baseDate.setDate(baseDate.getDate() + 1)
        }

        var nextSaturday = this.getNextDayOfWeek(baseDate, 6)
        nextSaturday.setHours(1)
        nextSaturday.setMinutes(0)
        nextSaturday.setSeconds(0)
        nextSaturday.setMilliseconds(0)

        var countDownTime = nextSaturday.getTime()
        var nowGMTTime
        var distance

        var x = setInterval(function () {
          d = new Date()
          nowGMTTime = new Date(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate(), d.getUTCHours(), d.getUTCMinutes(), d.getUTCSeconds(), d.getUTCMilliseconds()).getTime()
          distance = countDownTime - nowGMTTime

          self.weeklyCounterDays = Math.floor(distance / (1000 * 60 * 60 * 24))
          self.weeklyCounterHours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
          self.weeklyCounterMinutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60))
          self.weeklyCounterSeconds = Math.floor((distance % (1000 * 60)) / 1000)

          if (distance < 0) {
            clearInterval(x)
            self.weeklyCounterDays = 0
            self.weeklyCounterHours = 0
            self.weeklyCounterMinutes = 0
            self.weeklyCounterSeconds = 0
          }
        }, 1000)
      },
      counterMonthly () {
        var self = this
        var d = new Date()
        var baseDate = new Date(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate(), d.getUTCHours(), d.getUTCMinutes(), d.getUTCSeconds(), d.getUTCMilliseconds())

        if (baseDate.getDate() > 28 || (baseDate.getDate() === 28 && baseDate.getHours() >= 1)) {
          baseDate.setMonth(baseDate.getMonth() + 1)
        }

        baseDate.setDate(28)
        baseDate.setHours(1)
        baseDate.setMinutes(0)
        baseDate.setSeconds(0)
        baseDate.setMilliseconds(0)

        var countDownTime = baseDate.getTime()
        var nowGMTTime
        var distance

        var x = setInterval(function () {
          d = new Date()
          nowGMTTime = new Date(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate(), d.getUTCHours(), d.getUTCMinutes(), d.getUTCSeconds(), d.getUTCMilliseconds()).getTime()
          distance = countDownTime - nowGMTTime

          self.monthlyCounterDays = Math.floor(distance / (1000 * 60 * 60 * 24))
          self.monthlyCounterHours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
          self.monthlyCounterMinutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60))
          self.monthlyCounterSeconds = Math.floor((distance % (1000 * 60)) / 1000)

          if (distance < 0) {
            clearInterval(x)
            self.monthlyCounterDays = 0
            self.monthlyCounterHours = 0
            self.monthlyCounterMinutes = 0
            self.monthlyCounterSeconds = 0
          }
        }, 1000)
      },
      getNextDayOfWeek (date, dayOfWeek) {
        var resultDate = new Date(date.getTime())
        resultDate.setDate(date.getDate() + (7 + dayOfWeek - date.getDay()) % 7)
        return resultDate
      },
      async getPrizes () {
        var self = this
        try {
          var decodedResult = await this.callContractFunction(
            contractAddress,
            abiJson,
            'lotteryActive',
            [],
          )
          self.lotteryActive = decodedResult[0]

          if (self.lotteryActive) {
            decodedResult = await this.callContractFunction(
              contractAddress,
              abiJson,
              'dailyPrize',
              [],
            )
            self.dailyPrize = parseFloat(decodedResult[0]) / 100000000
            self.dailyPrizeUSD = (self.dailyPrize / (self.ticketPrice / 5)).toLocaleString('en-US', { style: 'currency', currency: 'USD' })

            decodedResult = await this.callContractFunction(
              contractAddress,
              abiJson,
              'weeklyPrize',
              [],
            )
            self.weeklyPrize = parseFloat(decodedResult[0]) / 100000000
            self.weeklyPrizeUSD = (self.weeklyPrize / (self.ticketPrice / 5)).toLocaleString('en-US', { style: 'currency', currency: 'USD' })

            decodedResult = await this.callContractFunction(
              contractAddress,
              abiJson,
              'monthlyPrize',
              [],
            )
            self.monthlyPrize = parseFloat(decodedResult[0]) / 100000000
            self.monthlyPrizeUSD = (self.monthlyPrize / (self.ticketPrice / 5)).toLocaleString('en-US', { style: 'currency', currency: 'USD' })

            decodedResult = await this.callContractFunction(
              contractAddress,
              abiJson,
              'superTicketsPrize',
              [],
            )
            self.superTicketsPrize = parseFloat(decodedResult[0]) / 100000000
            self.superTicketsPrizeUSD = (self.superTicketsPrize / (self.ticketPrice / 5)).toLocaleString('en-US', { style: 'currency', currency: 'USD' })
          }

          self.loadingPrizes = false
        } catch (e) {
          console.log('Error reading prizes: ' + e.stack || e.toString() || e)
          alert(e.message || e)
        }
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
    },
  }
</script>
