import Vue from 'vue'
import Vuex from 'vuex'

// Modules
import app from '@/store/modules/app'
import auth from '@/store/modules/auth'
import downloads from '@/store/modules/downloads'
import prizes from '@/store/modules/prizes'
import games from '@/store/modules/games'
import howToPlay from '@/store/modules/how-to-play'
import install from '@/store/modules/install'
import library from '@/store/modules/library'
import snackbar from '@/store/modules/snackbar'
import verify from '@/store/modules/verify'

Vue.use(Vuex)

const store = new Vuex.Store({
  modules: {
    app,
    auth,
    downloads,
    prizes,
    games,
    howToPlay,
    install,
    library,
    snackbar,
    verify,
  },
  actions: {
    init: async () => {
      await Promise.all([])
    },
  },
})

store.dispatch('init')

export default store
