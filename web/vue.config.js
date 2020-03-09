module.exports = {
  devServer: {
    disableHostCheck: true,
  },

  configureWebpack: {
    resolve: {
      symlinks: false,
    },
  },

  chainWebpack: config => config.optimization.minimize(false),

  transpileDependencies: ['vuetify'],
}
