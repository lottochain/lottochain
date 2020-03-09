export default {
  namespaced: true,

  state: {
    featured: [],
    games: [
      {
        id: 1,
        name: 'Golden Chess',
        src: 'golden-chess',
        updated: 2,
        ready: false,
        content: false,
        p1: '<p>Golden Chess is going to be a great opportunity for all chess enthusiasts to earn crypto currency while playing online!</p>',
        p2: '',
        p3: '',
      },
      {
        id: 2,
        name: 'Lottochain',
        src: 'lottochain-main-banner',
        updated: 1,
        ready: false,
        content: false,
      },
      {
        id: 3,
        name: 'Token Tower',
        src: 'token-tower',
        updated: 3,
        content: true,
        p1: '<p>Token Tower is a company focused on blockchain solutions</p>',
        p2: '<a href="https://tokentower.tech" target="_blank">HTML Bunker</a>',
        p3: '',
      },
      {
        id: 4,
        name: 'HTML Poker',
        src: 'html-poker',
        updated: 2,
        ready: false,
        content: false,
        p1: '<p>HTML Poker is going to be a great opportunity for all chess enthusiasts to earn crypto currency while playing online!</p>',
        p2: '',
        p3: '',
      },
      {
        id: 5,
        name: 'HTMLBunker',
        src: 'htmlbunker',
        updated: 3,
        content: true,
        p1: '<p>HTML Bunker is a dedicated exchange.</p>',
        p2: '<a href="https://htmlbunker.com" target="_blank">HTML Bunker</a>',
        p3: '',
      },
      {
        id: 6,
        buyColor: '#3675A6',
        name: 'Purchase HTML',
        src: 'purchase-html',
        updated: 0,
        content: true,
        p1: '<p>Lottochain Tickets are purchaseable only with HTML, which is the a crypto currency.</p>',
        p2: '<p>You can acquire HTML in <a href="https://htmlbunker.com">HTML Bunker</a>, an exchange created to be a dedicated hub for HTMLCoin community.',
        p3: '<p>Just access the URL above, sign up and soon enough you will be able to exchange all major currencies for HTML.',
      },
      {
        id: 7,
        buyColor: '#804C9D',
        name: 'Lottochain Features',
        src: 'lottochain-features',
        updated: 0,
        content: true,
        p1: '<p>Lottochain is a safe lottery implemented over smart contracts on Althash, the blockchain of HTMLCoin.</p>',
        p2: '<p>With a single ticket you have 3 chances to win daily, weekly and monthly prizes.<br>50% of all tickets are drawn daily amongst all people who bought tickets on that day. Similarly, 20% of all tickets purchased in a week are drawn amongst everyone who has purchased tickets in that week. Moreover, 10% of all tickets traded in the month are drawn amongst whoever bought tickets in that month.</p>',
        p3: '<p>Lottochain is a fair, auditable and decentralized lottery.</p>',
      },
      {
        id: 8,
        name: 'Rolling the Lucky',
        src: 'rolling-the-lucky',
        updated: 2,
        ready: false,
        content: false,
        p1: '<p>Rolling the Lucky is going to be a great opportunity for all chess enthusiasts to earn crypto currency while playing online!</p>',
        p2: '',
        p3: '',
      },
      {
        id: 9,
        name: 'Lottochain News',
        src: 'lottochain-news',
        updated: 0,
        content: true,
        p1: '<p><b>Lottochain is released on the 29/02/2020</b></p>',
        p2: '<p>The Lottochain team is pleased to announce that Lottochain has been activated and tickets are already purchaseable.</p>',
        p3: '<p>Do not miss out and go get your tickets!</p>',
      },
      {
        id: 10,
        name: 'About HTMLCOIN',
        src: 'about-htmlcoin',
        updated: 3,
        content: true,
        p1: '<p>The HTMLCOIN Foundation exists since 2014</p>',
        p2: '<p>Amando Boncales had a vision and did not hesitate to put it in practice.</p>',
        p3: '',
      },
    ],
  },

  getters: {
    featured: (state, getters) => {
      return getters.parsedGames.sort((a, b) => {
        if (a.updated < b.updated) return -1
        if (a.updated > b.updated) return 1
        return 0
      }).slice(0, 3)
    },
    parsedGames: state => {
      return state.games.map(game => ({
        ...game,
        bg: `games/${game.src}/bg.png`,
        bg2: `games/${game.src}/bg2.png`,
        logo: `games/${game.src}/logo.png`,
        avatar: `games/${game.src}/avatar.png`,
      })).sort((a, b) => {
        if (a.updated < b.updated) return -1
        if (a.updated > b.updated) return 1
        return 0
      })
    },
  },
}
