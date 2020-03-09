import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)

const router = new Router({
  mode: 'history',
  base: process.env.BASE_URL,
  scrollBehavior: () => ({ x: 0, y: 0 }),
  routes: [
    {
      path: '/',
      name: 'Home',
      component: () => import('@/views/home/Index'),
    },
    {
      path: '/article/:slug',
      name: 'Article',
      component: () => import('@/views/article/Index'),
    },
    {
      path: '/games',
      name: 'Games',
      component: () => import('@/views/library/Index'),
    },
    {
      path: '/how-to-play',
      name: 'How to Play',
      component: () => import('@/views/how-to-play/Index'),
    },
    {
      path: '/buy-tickets',
      name: 'Buy Tickets',
      component: () => import('@/views/buy-tickets/Index'),
    },
    {
      path: '/:id',
      name: 'StorePage',
      component: () => import('@/views/store-page/Index'),
    },
  ],
})

// Bootstrap Analytics
// Set in .env
// https://github.com/MatteoGabriele/vue-analytics
if (process.env.VUE_APP_GOOGLE_ANALYTICS) {
  Vue.use(require('vue-analytics').default, {
    id: process.env.VUE_APP_GOOGLE_ANALYTICS,
    router,
    autoTracking: {
      page: process.env.NODE_ENV !== 'development',
    },
  })
}

export default router
