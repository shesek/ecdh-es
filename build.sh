#!/bin/sh
coffee -o lib -c src
browserify lib/ecdh.js -s ECDH > dist/ecdh.js
uglifyjs dist/ecdh.js > dist/ecdh.min.js
