const { environment } = require('@rails/webpacker')
const { VueLoaderPlugin } = require("vue-loader");
const vue =  require('./loaders/vue')

const babelLoader = environment.loaders.get("babel");

environment.loaders.insert(
  "svg",
  {
    test: /\.svg$/,
    use: babelLoader.use.concat([
      {
        loader: "vue-svg-loader"
      }
    ])
  },
  { before: "file" }
);

const fileLoader = environment.loaders.get("file");
fileLoader.exclude = /\.(svg)$/i;

environment.plugins.prepend("VueLoaderPlugin", new VueLoaderPlugin());
environment.loaders.prepend('vue', vue)
module.exports = environment
