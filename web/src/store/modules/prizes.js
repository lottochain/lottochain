import { set, toggle } from '@/utils/vuex'

export default {
  namespaced: true,

  state: {
    drawer: null,
    prizes: [
      {
        id: 1,
        name: 'John Smith',
        online: true,
        game: {
          id: 10,
          logo: 'games/storm-peak/avatar.png',
          name: 'Battle of StormPeak',
        },
      },
      {
        id: 2,
        name: 'Jane Smith',
        online: true,
      },
      {
        id: 3,
        name: 'Jimmy Doe',
        online: false,
      },
      {
        id: 4,
        name: 'Charles Edward Cheese',
        online: false,
      },
    ],
  },

  getters: {
    online: state => {
      const total = state.prizes.length
      const online = state.prizes.filter(friend => friend.online).length

      return `(${online}/${total})`
    },
  },

  mutations: {
    setDrawer: set('drawer'),
    toggleDrawer: toggle('drawer'),
  },
}
