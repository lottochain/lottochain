<template>
  <articles />
</template>

<script>
  export default {
    name: 'HowToPlay',

    components: {
      Articles: () => import('./Articles'),
    },
  }
</script>
