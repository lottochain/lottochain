<template>
  <v-container
    v-if="article"
    class="article pt-0 px-0"
  >
    <v-img
      :src="require(`@/assets/${article.img}`)"
      gradient="to bottom, rgba(0,0,0,.4), rgba(0,0,0,0)"
      height="50vh"
    >
      <router-link to="/">
        <v-subheader>
          Back to Home
        </v-subheader>
      </router-link>
    </v-img>

    <v-sheet
      class="py-5 px-3"
      color="grey lighten-2"
      light
    >
      <h1
        class="title font-weight-bold mb-4 mx-5"
        v-text="article.title"
      />

      <v-row>
        <v-col class="grey--text text--darken-2 subtitle-2 font-weight-light mx-5">
          <span v-html="article.p1" />
          <span v-html="article.p2" />
          <span v-html="article.p3" />
        </v-col>
      </v-row>
    </v-sheet>
  </v-container>
</template>

<script>
  // Utilities
  import {
    mapState,
  } from 'vuex'

  export default {
    name: 'Article',

    computed: {
      ...mapState('howToPlay', ['articles']),
      ...mapState('route', ['params']),
      article () {
        return this.articles.find(article => article.slug === this.params.slug)
      },
    },
  }
</script>

<style lang="scss">
.article {
  p {
    line-height: 2;
    padding: 0 12px 20px;
  }
}
</style>
