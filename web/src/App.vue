<template>
  <v-app class="grey darken-4">
    <core-app-bar />

    <core-audit />

    <core-drawer />

    <core-view />

    <core-prizes :key="refreshKey" />

    <core-snackbar />
  </v-app>
</template>

<script>
  export default {
    components: {
      CoreAppBar: () => import('@/components/core/AppBar'),
      CoreAudit: () => import('@/components/core/Audit'),
      CoreDrawer: () => import('@/components/core/Drawer'),
      CorePrizes: () => import('@/components/core/Prizes'),
      CoreSnackbar: () => import('@/components/core/Snackbar'),
      CoreView: () => import('@/components/core/View'),
    },
    data () {
      return {
        refreshKey: 0,
      }
    },
    mounted () {
      this.refreshPrizes()
    },
    methods: {
      refreshPrizes () {
        var self = this
        setInterval(function () {
          self.refreshKey += 1
        }, 1000 * 60 * 5)
      },
    },
  }
</script>

<style>
.v-card {
  border-radius: 6px;
}
a {
  text-decoration: none;
}
</style>
