module.exports = function(api) {
  api.cache(true);

  const plugins = ["module-resolver", {
    "alias": {
      "^react-native$": "react-native-web"
    }
  }]

  return {
    presets: ['babel-preset-expo'],
    plugins
  };
};
