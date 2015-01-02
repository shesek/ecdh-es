# extract just the required bits from `crypto-browserify` to make the bundle smaller
# (browserify is instructed to use this file using the `browser` field in package.json)
exports.createHash = require 'crypto-browserify/create-hash'
exports.createHmac = require 'crypto-browserify/create-hmac'
require('crypto-browserify/node_modules/browserify-aes/inject')(exports, exports)
