<template>
  <v-container class="py-0">
    <v-img
      :src="require(`@/assets/${game.bg}`)"
      min-height="50vh"
    >
      <router-link to="/">
        <v-subheader>
          Back to Home
        </v-subheader>
      </router-link>
      <v-row
        class="fill-height"
        justify="center"
        align="center"
      >
        <v-col class="text-center">
          <v-img
            :src="require(`@/assets/${game.logo}`)"
            contain
            class="mx-auto mb-5"
            width="200"
          />

          <v-btn
            v-if="!game.content && game.ready"
            :color="game.buyColor || 'blue'"
            style="min-width: 225px; height: 52px;"
          >
            Play
          </v-btn>
        </v-col>
      </v-row>
    </v-img>
    <v-sheet
      class="py-5 px-3"
      color="grey lighten-2"
      light
    >
      <h1
        class="title font-weight-bold mb-4 mx-5"
        v-text="game.name"
      />
      <v-row
        align="center"
      >
        <v-col class="grey--text text--darken-2 mx-5">
          <span
            class="subtitle-2"
            v-html="game.p1"
          />
          <span
            class="subtitle-2"
            v-html="game.p2"
          />
          <span
            class="subtitle-2"
            v-html="game.p3"
          />
        </v-col>
      </v-row>
    </v-sheet>
    <v-sheet
      height="400"
      color="grey darken-2"
      tile
    />
    <v-sheet
      height="200"
      color="grey darken-3"
      tile
    />
  </v-container>
</template>

<script>
  // Utilities
  import {
    mapGetters,
    mapState,
  } from 'vuex'

  export default {
    name: 'StorePage',

    computed: {
      ...mapGetters('games', ['parsedGames']),
      ...mapState('route', ['params']),
      game () {
        return this.parsedGames.find(game => Number(game.id) === Number(this.params.id))
      },
    },
  }
</script>
