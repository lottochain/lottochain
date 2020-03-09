<template>
  <v-container>
    <v-row>
      <v-col
        v-for="game in filteredGames"
        :key="game.id"
        cols="12"
        sm="6"
        md="4"
      >
        <game
          :value="game"
          :understate="!game.installed"
          dense
          static
        />
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
  // Utilities
  import {
    mapGetters,
  } from 'vuex'

  export default {
    name: 'LibraryGames',

    components: {
      Game: () => import('@/components/Game'),
    },

    computed: {
      ...mapGetters('library', ['games']),
      filteredGames: function () {
        return this.games.filter(function (i) {
          return i.content === false
        })
      },
    },
  }
</script>

<style scoped>
.v-sheet {
  cursor: pointer;
}
</style>
