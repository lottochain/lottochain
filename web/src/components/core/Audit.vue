<template>
  <v-navigation-drawer
    v-model="model"
    :style="styles"
    class="grey darken-3"
    disable-resize-watcher
    fixed
    touchless
    width="650"
  >
    <template v-if="model">
      <v-row
        class="pa-5 mx-5 title"
      >
        Audit & Follow Lottochain Draws
        <v-btn
          class="mx-2"
          icon
          @click="getDraws"
        >
          <v-icon>mdi-refresh</v-icon>
        </v-btn>
        <v-spacer />
        <v-btn
          class="ma-0"
          icon
          @click="setDrawer(false)"
        >
          <v-icon>mdi-close</v-icon>
        </v-btn>
      </v-row>

      <template v-if="loadingDraws">
        <v-row
          class="pa-5"
          justify="center"
        >
          <v-spacer />
          <v-progress-circular
            :size="70"
            :width="7"
            indeterminate
            color="red"
          />
          <v-spacer />
        </v-row>
      </template>
      <template v-else>
        <v-list>
          <v-divider class="px-5 mx-5" />
          <v-list-item>
            <v-list-item-content>
              <span class="caption">
                Lottochain official timezone is&nbsp;
                <a
                  href="https://time.is/GMT"
                  target="_blank"
                >
                  <b>
                    GMT
                  </b>
                </a>.
              </span>
            </v-list-item-content>
          </v-list-item>
          <v-divider class="px-5 mx-5" />
          <v-list-group prepend-icon="mdi-calendar-check">
            <template v-slot:activator>
              <v-list-item-title>Recent Daily Draws</v-list-item-title>
            </template>

            <v-list-item>
              <v-list-item-content>
                <v-treeview
                  class="caption"
                  transition
                  dense
                  :items="dailyDraws"
                />
              </v-list-item-content>
            </v-list-item>
          </v-list-group>
          <v-divider class="px-5 mx-5" />
          <v-list-group prepend-icon="mdi-calendar-check">
            <template v-slot:activator>
              <v-list-item-title>Last Weekly Draw (Every Saturday)</v-list-item-title>
            </template>

            <v-list-item>
              <v-list-item-content>
                <v-treeview
                  class="caption"
                  transition
                  dense
                  open-all
                  :items="weeklyDraw"
                />
              </v-list-item-content>
            </v-list-item>
          </v-list-group>
          <v-divider class="px-5 mx-5" />
          <v-list-group prepend-icon="mdi-calendar-check">
            <template v-slot:activator>
              <v-list-item-title>Last Monthly Draw (Every 28th)</v-list-item-title>
            </template>

            <v-list-item>
              <v-list-item-content>
                <v-treeview
                  class="caption"
                  transition
                  dense
                  open-all
                  :items="monthlyDraw"
                />
              </v-list-item-content>
            </v-list-item>
          </v-list-group>
          <v-divider class="px-5 mx-5" />
          <v-list-group prepend-icon="mdi-calendar-check">
            <template v-slot:activator>
              <v-list-item-title>Last Super Ticket Draw (Every 28th)</v-list-item-title>
            </template>

            <v-list-item>
              <v-list-item-content>
                <v-treeview
                  class="caption"
                  transition
                  dense
                  open-all
                  :items="superTicketsDraw"
                />
              </v-list-item-content>
            </v-list-item>
          </v-list-group>
          <v-divider class="px-5 mx-5" />
        </v-list>
        <v-row class="py-2 px-5 mx-5 subtitle-1">
          <v-select
            v-model="manualSelection"
            :items="manualSelectionOptions"
            label="Manual search"
            flat
            solo
            @change="yesterday"
          />
        </v-row>
        <v-row
          v-if="manualSelection === 'Daily' && showCalendar"
          justify="center"
        >
          <v-date-picker
            v-model="manuallySelectedDate"
            :max="maxPickDate"
            landscape
            show-current
            @change="getManuallySearchedDraw"
          />
        </v-row>
        <v-row
          v-if="manualSelection === 'Weekly' && showCalendar"
          justify="center"
        >
          <v-date-picker
            v-model="manuallySelectedDate"
            :allowed-dates="allowedDates"
            :max="maxPickDate"
            landscape
            show-current
            @change="getManuallySearchedDraw"
          />
        </v-row>
        <v-row
          v-if="manualSelection === 'Monthly' && showCalendar"
          justify="center"
        >
          <v-date-picker
            v-model="manuallySelectedDate"
            :max="maxPickDate"
            landscape
            type="month"
            @change="getManuallySearchedDraw"
          />
        </v-row>
        <v-row
          v-if="manualSelection === 'Super Ticket' && showCalendar"
          justify="center"
        >
          <v-date-picker
            v-model="manuallySelectedDate"
            :max="maxPickDate"
            landscape
            type="month"
            @change="getManuallySearchedDraw"
          />
        </v-row>
        <v-row v-if="loadingManuallySelectedDraw">
          <v-spacer />
          <v-progress-circular
            indeterminate
            color="red"
          />
          <v-spacer />
        </v-row>
        <template v-if="manuallySearchedResult">
          <v-row justify="center">
            <v-btn
              icon
              @click="newManualSearch"
            >
              <v-icon>mdi-refresh</v-icon>
            </v-btn>
          </v-row>
          <v-row>
            <v-treeview
              class="caption mx-5"
              transition
              dense
              open-all
              :items="manuallySearchedDraw"
            />
          </v-row>
        </template>
      </template>
    </template>
  </v-navigation-drawer>
</template>

<script>
  import config from '../../libs/config'
  import server from '../../libs/server'
  import abi from 'ethjs-abi'
  import base58check from 'base58check'

  // Utilities
  import {
    mapGetters,
    mapMutations,
    mapState,
  } from 'vuex'

  const prefix = config.getNetwork() === 'mainnet' ? '29' : '64'

  const contractAddress = config.getNetwork() === 'mainnet' ? 'ced6ccc8eead0970c8f178062779d5c547a53de7' : 'ac84457145f4e0330629a3f58032305fbfaa2854'

  const abiJson = JSON.parse(
    '[{"constant": true, "inputs": [], "name": "dailyPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "ticketPrice", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [{"name": "", "type": "uint256"} ], "name": "weeklyTickets", "outputs": [{"name": "", "type": "address"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "accumulatedWeeklyPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "accumulatedDailyPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "weeklyPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [{"name": "_address", "type": "address"} ], "name": "getAddressCurrentTicketQty", "outputs": [{"name": "dailyTicketsBalance", "type": "uint256"}, {"name": "weeklyTicketsBalance", "type": "uint256"}, {"name": "monthlyTicketsBalance", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "accumulatedSuperTicketsPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "superTicketsPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "superTicketPrice", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "accumulatedMonthlyPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [{"name": "", "type": "uint256"} ], "name": "monthlyTickets", "outputs": [{"name": "", "type": "address"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [{"name": "", "type": "uint256"} ], "name": "dailyTickets", "outputs": [{"name": "", "type": "address"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "lotteryActive", "outputs": [{"name": "", "type": "bool"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [], "name": "monthlyPrize", "outputs": [{"name": "", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": true, "inputs": [{"name": "_drawDate", "type": "uint256"}, {"name": "_drawType", "type": "uint8"} ], "name": "drawsHistory", "outputs": [{"name": "hashDraw1", "type": "bytes32"}, {"name": "hashDraw2", "type": "bytes32"}, {"name": "drawnAddress", "type": "address"}, {"name": "blockNumber", "type": "uint256"}, {"name": "prize", "type": "uint256"} ], "payable": false, "stateMutability": "view", "type": "function"}, {"constant": false, "inputs": [], "name": "buyTicket", "outputs": [], "payable": true, "stateMutability": "payable", "type": "function"} ]',
  )

  export default {
    name: 'CoreDownloads',

    data () {
      return {
        loadingDraws: true,
        manualSelection: '',
        manualSelectionOptions: ['Daily', 'Weekly', 'Monthly', 'Super Ticket'],
        manuallySelectedDate: '',
        loadingManuallySelectedDraw: false,
        manuallySearchedResult: false,
        showCalendar: false,
        maxPickDate: '',
        dailyDraws: [],
        weeklyDraw: [],
        monthlyDraw: [],
        superTicketsDraw: [],
        manuallySearchedDraw: [],
      }
    },

    computed: {
      ...mapGetters('games', ['parsedGames']),
      ...mapState('downloads', [
        'drawer',
        'downloading',
      ]),
      downloads () {
        return this.downloading.map(download => {
          return this.parsedGames.find(game => game.id === download)
        })
      },
      model: {
        get () {
          return this.drawer
        },
        set (val) {
          this.setDrawer(val)
        },
      },
      styles () {
        const styles = {}

        if (this.$vuetify.breakpoint.lgAndUp) {
          styles.left = '200px'
        } else {
          styles.left = 0
        }

        return styles
      },
    },

    async mounted () {
      await this.getDraws()
    },

    methods: {
      ...mapMutations('downloads', ['setDrawer']),
      yyyymmdd (x) {
        x = new Date(x)
        var y = x.getFullYear().toString()
        var m = (x.getMonth() + 1).toString()
        var d = x.getDate().toString()
        if (d.length === 1) {
          d = '0' + d
        }
        if (m.length === 1) {
          m = '0' + m
        }
        var yyyymmdd = y + m + d
        return yyyymmdd
      },
      yesterday () {
        var self = this
        self.manuallySearchedDraw.pop()
        self.manuallySearchedResult = false
        self.showCalendar = true
        var workingDate = new Date()
        workingDate.setDate(workingDate.getDate() - 1)
        const year = workingDate.getFullYear()
        var month = workingDate.getMonth() + 1
        if (month < 10) {
          month = '0' + month
        }
        var day = workingDate.getDate()
        if (day < 10) {
          day = '0' + day
        }
        self.maxPickDate = year + '-' + month + '-' + day
      },
      allowedDates: val => (new Date(val.split('-')[0], parseInt(val.split('-')[1]) - 1, val.split('-')[2]).getDay()) === 6,
      newManualSearch () {
        var self = this
        self.manuallySearchedResult = false
        self.manuallySearchedDraw.pop()
        self.showCalendar = true
      },
      async getManuallySearchedDraw () {
        var self = this
        var drawCode
        switch (self.manualSelection) {
          case 'Daily':
            drawCode = 1
            break
          case 'Weekly':
            drawCode = 2
            break
          case 'Monthly':
            drawCode = 3
            self.manuallySelectedDate += '-28'
            break
          case 'Super Ticket':
            drawCode = 4
            self.manuallySelectedDate += '-28'
            break
        }
        self.showCalendar = false
        self.loadingManuallySelectedDraw = true
        try {
          var decodedResult = await this.callContractFunction(
            contractAddress,
            abiJson,
            'drawsHistory',
            [self.manuallySelectedDate.replace(/-/g, ''), drawCode],
          )
          if (decodedResult[0] !== '0x0000000000000000000000000000000000000000000000000000000000000000') {
            self.manuallySearchedDraw.push(
              {
                name: self.manuallySelectedDate,
                children: [
                  {
                    name: 'Hash HTML: ' + decodedResult[0].substring(2),
                  },
                  {
                    name: 'Hash BTC: ' + decodedResult[1].substring(2),
                  },
                  {
                    name: 'Winner: ' + base58check.encode(decodedResult[2].substring(2), prefix),
                  },
                  {
                    name: 'Block Number: ' + decodedResult[3],
                  },
                  {
                    name: 'Prize: ' + (parseFloat(decodedResult[4]) / 100000000).toLocaleString('en-US', { style: 'decimal', minimumFractionDigits: 8 }) + ' HTML',
                  },
                ],
              },
            )
            self.manuallySearchedResult = true
          } else {
            alert('There was no draw on the selected day.')
            self.showCalendar = true
          }
        } catch (e) {
          console.log('Error reading prizes for manual search: ' + e.stack || e.toString() || e)
          alert(e.message || e)
        }
        self.loadingManuallySelectedDraw = false
      },
      async getDraws () {
        var self = this
        self.loadingDraws = true
        var d = new Date()
        var workingDate = new Date(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate(), d.getUTCHours(), d.getUTCMinutes(), d.getUTCSeconds(), d.getUTCMilliseconds())
        var last28th
        if (workingDate.getMonth() === 1) {
          last28th = this.yyyymmdd(new Date(workingDate.getFullYear() - 1, 12, 28, 22, 0, 0, 0))
        } else {
          last28th = this.yyyymmdd(new Date(workingDate.getFullYear(), workingDate.getMonth() - 1, 28, 22, 0, 0, 0))
        }
        const lastSaturday = this.yyyymmdd(this.getLastSaturday())
        const todayMinus1 = this.yyyymmdd(workingDate.setDate(workingDate.getDate() - 1))
        const todayMinus2 = this.yyyymmdd(workingDate.setDate(workingDate.getDate() - 1))
        const todayMinus3 = this.yyyymmdd(workingDate.setDate(workingDate.getDate() - 1))
        const todayMinus4 = this.yyyymmdd(workingDate.setDate(workingDate.getDate() - 1))
        const todayMinus5 = this.yyyymmdd(workingDate.setDate(workingDate.getDate() - 1))
        try {
          var decodedResult = await this.callContractFunction(
            contractAddress,
            abiJson,
            'drawsHistory',
            [todayMinus1, 1],
          )
          if (decodedResult[0] !== '0x0000000000000000000000000000000000000000000000000000000000000000') {
            self.dailyDraws.push(
              {
                name: todayMinus1.substring(0, 4) + '-' + todayMinus1.substring(4, 6) + '-' + todayMinus1.substring(6),
                children: [
                  {
                    name: 'Hash HTML: ' + decodedResult[0].substring(2),
                  },
                  {
                    name: 'Hash BTC: ' + decodedResult[1].substring(2),
                  },
                  {
                    name: 'Winner: ' + base58check.encode(decodedResult[2].substring(2), prefix),
                  },
                  {
                    name: 'Block Number: ' + decodedResult[3],
                  },
                  {
                    name: 'Prize: ' + (parseFloat(decodedResult[4]) / 100000000).toLocaleString('en-US', { style: 'decimal', minimumFractionDigits: 8 }) + ' HTML',
                  },
                ],
              },
            )
          }

          decodedResult = await this.callContractFunction(
            contractAddress,
            abiJson,
            'drawsHistory',
            [todayMinus2, 1],
          )
          if (decodedResult[0] !== '0x0000000000000000000000000000000000000000000000000000000000000000') {
            self.dailyDraws.push(
              {
                name: todayMinus2.substring(0, 4) + '-' + todayMinus1.substring(4, 6) + '-' + todayMinus1.substring(6),
                children: [
                  {
                    name: 'Hash HTML: ' + decodedResult[0].substring(2),
                  },
                  {
                    name: 'Hash BTC: ' + decodedResult[1].substring(2),
                  },
                  {
                    name: 'Winner: ' + base58check.encode(decodedResult[2].substring(2), prefix),
                  },
                  {
                    name: 'Block Number: ' + decodedResult[3],
                  },
                  {
                    name: 'Prize: ' + (parseFloat(decodedResult[4]) / 100000000).toLocaleString('en-US', { style: 'decimal', minimumFractionDigits: 8 }) + ' HTML',
                  },
                ],
              },
            )
          }

          decodedResult = await this.callContractFunction(
            contractAddress,
            abiJson,
            'drawsHistory',
            [todayMinus3, 1],
          )
          if (decodedResult[0] !== '0x0000000000000000000000000000000000000000000000000000000000000000') {
            self.dailyDraws.push(
              {
                name: todayMinus3.substring(0, 4) + '-' + todayMinus1.substring(4, 6) + '-' + todayMinus1.substring(6),
                children: [
                  {
                    name: 'Hash HTML: ' + decodedResult[0].substring(2),
                  },
                  {
                    name: 'Hash BTC: ' + decodedResult[1].substring(2),
                  },
                  {
                    name: 'Winner: ' + base58check.encode(decodedResult[2].substring(2), prefix),
                  },
                  {
                    name: 'Block Number: ' + decodedResult[3],
                  },
                  {
                    name: 'Prize: ' + (parseFloat(decodedResult[4]) / 100000000).toLocaleString('en-US', { style: 'decimal', minimumFractionDigits: 8 }) + ' HTML',
                  },
                ],
              },
            )
          }

          decodedResult = await this.callContractFunction(
            contractAddress,
            abiJson,
            'drawsHistory',
            [todayMinus4, 1],
          )
          if (decodedResult[0] !== '0x0000000000000000000000000000000000000000000000000000000000000000') {
            self.dailyDraws.push(
              {
                name: todayMinus4.substring(0, 4) + '-' + todayMinus1.substring(4, 6) + '-' + todayMinus1.substring(6),
                children: [
                  {
                    name: 'Hash HTML: ' + decodedResult[0].substring(2),
                  },
                  {
                    name: 'Hash BTC: ' + decodedResult[1].substring(2),
                  },
                  {
                    name: 'Winner: ' + base58check.encode(decodedResult[2].substring(2), prefix),
                  },
                  {
                    name: 'Block Number: ' + decodedResult[3],
                  },
                  {
                    name: 'Prize: ' + (parseFloat(decodedResult[4]) / 100000000).toLocaleString('en-US', { style: 'decimal', minimumFractionDigits: 8 }) + ' HTML',
                  },
                ],
              },
            )
          }

          decodedResult = await this.callContractFunction(
            contractAddress,
            abiJson,
            'drawsHistory',
            [todayMinus5, 1],
          )
          if (decodedResult[0] !== '0x0000000000000000000000000000000000000000000000000000000000000000') {
            self.dailyDraws.push(
              {
                name: todayMinus5.substring(0, 4) + '-' + todayMinus1.substring(4, 6) + '-' + todayMinus1.substring(6),
                children: [
                  {
                    name: 'Hash HTML: ' + decodedResult[0].substring(2),
                  },
                  {
                    name: 'Hash BTC: ' + decodedResult[1].substring(2),
                  },
                  {
                    name: 'Winner: ' + base58check.encode(decodedResult[2].substring(2), prefix),
                  },
                  {
                    name: 'Block Number: ' + decodedResult[3],
                  },
                  {
                    name: 'Prize: ' + (parseFloat(decodedResult[4]) / 100000000).toLocaleString('en-US', { style: 'decimal', minimumFractionDigits: 8 }) + ' HTML',
                  },
                ],
              },
            )
          }

          decodedResult = await this.callContractFunction(
            contractAddress,
            abiJson,
            'drawsHistory',
            [lastSaturday, 2],
          )
          if (decodedResult[0] !== '0x0000000000000000000000000000000000000000000000000000000000000000') {
            self.weeklyDraw.push(
              {
                name: lastSaturday.substring(0, 4) + '-' + lastSaturday.substring(4, 6) + '-' + lastSaturday.substring(6),
                children: [
                  {
                    name: 'Hash HTML: ' + decodedResult[0].substring(2),
                  },
                  {
                    name: 'Hash BTC: ' + decodedResult[1].substring(2),
                  },
                  {
                    name: 'Winner: ' + base58check.encode(decodedResult[2].substring(2), prefix),
                  },
                  {
                    name: 'Block Number: ' + decodedResult[3],
                  },
                  {
                    name: 'Prize: ' + (parseFloat(decodedResult[4]) / 100000000).toLocaleString('en-US', { style: 'decimal', minimumFractionDigits: 8 }) + ' HTML',
                  },
                ],
              },
            )
          }

          decodedResult = await this.callContractFunction(
            contractAddress,
            abiJson,
            'drawsHistory',
            [last28th, 3],
          )
          if (decodedResult[0] !== '0x0000000000000000000000000000000000000000000000000000000000000000') {
            self.monthlyDraw.push(
              {
                name: last28th.substring(0, 4) + '-' + last28th.substring(4, 6) + '-' + last28th.substring(6),
                children: [
                  {
                    name: 'Hash HTML: ' + decodedResult[0].substring(2),
                  },
                  {
                    name: 'Hash BTC: ' + decodedResult[1].substring(2),
                  },
                  {
                    name: 'Winner: ' + base58check.encode(decodedResult[2].substring(2), prefix),
                  },
                  {
                    name: 'Block Number: ' + decodedResult[3],
                  },
                  {
                    name: 'Prize: ' + (parseFloat(decodedResult[4]) / 100000000).toLocaleString('en-US', { style: 'decimal', minimumFractionDigits: 8 }) + ' HTML',
                  },
                ],
              },
            )
          }

          decodedResult = await this.callContractFunction(
            contractAddress,
            abiJson,
            'drawsHistory',
            [last28th, 4],
          )
          if (decodedResult[0] !== '0x0000000000000000000000000000000000000000000000000000000000000000') {
            self.superTicketsDraw.push(
              {
                name: last28th.substring(0, 4) + '-' + last28th.substring(4, 6) + '-' + last28th.substring(6),
                children: [
                  {
                    name: 'Hash HTML: ' + decodedResult[0].substring(2),
                  },
                  {
                    name: 'Hash BTC: ' + decodedResult[1].substring(2),
                  },
                  {
                    name: 'Winner: ' + base58check.encode(decodedResult[2].substring(2), prefix),
                  },
                  {
                    name: 'Block Number: ' + decodedResult[3],
                  },
                  {
                    name: 'Prize: ' + (parseFloat(decodedResult[4]) / 100000000).toLocaleString('en-US', { style: 'decimal', minimumFractionDigits: 8 }) + ' HTML',
                  },
                ],
              },
            )
          }

          self.loadingDraws = false
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
      getLastSaturday () {
        var resultDate = new Date()
        resultDate.setDate(resultDate.getDate() - resultDate.getDay() - 1)
        return resultDate
      },
    },
  }
</script>
