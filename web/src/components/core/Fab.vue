<template>
  <v-btn
    bottom
    color="light-green darken-2"
    fab
    fixed
    right
    style="z-index: 9"
    @click="toggleDrawer"
  >
    <v-icon>mdi-trophy</v-icon>
  </v-btn>
</template>

<script>
  // Utilities
  import {
    mapMutations,
  } from 'vuex'

  export default {
    name: 'CoreFab',

    methods: {
      ...mapMutations('prizes', ['toggleDrawer']),
    },
  }
</script>
