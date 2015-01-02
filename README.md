# ecdh-es [![npm](https://img.shields.io/npm/v/ecdh-es.svg)](http://npmjs.org/package/ecdh-es) ![npm](https://img.shields.io/npm/l/ecdh-es.svg)

Elliptic Curve Diffie-Hellman with ephemeral-static keys implementation for NodeJS

### Install

    npm install --save ecdh-es

### Use
    var ecdh = require('ecdh-es')
      , pubkey = new Buffer('03a34b99f22c790c4e36b2b3c2c35a36db06226e41c692fc82b8b56ac1c540c5bd', 'hex')
      , privkey = new Buffer('e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'hex')

    var encrypted = ecdh.encrypt(pubkey, 'Hello, world!') // -> Buffer
    var decrypted = ecdh.decrypt(privkey, encrypted) // -> Buffer
    // (use toString() to convert back to string message)

    // Uses the secp256k1 curve and AES-128-CBC cipher by default,
    // but can be overridden as follows:
    var ecdh = require('ecdh-es')({
      curve_name: 'secp192k1',
      cipher_algo: 'AES-256-CBC',
      key_size: 32,
      iv_size: 16
    })

### Browser usage
If you're using browserify to bundle your code, you can use this package
normally and everything should work the same.
Note, however, that
[crypto-browserify](https://github.com/dominictarr/crypto-browserify)
(which is used as a shim for nodejs's `crypto` api)
only support AES encryption.

If you're not using browserify, you can use the standalone bundle at `dist/ecdh.min.js`,
which comes packaged with all of the dependencies.
Including it in your page will provide global `ECDH` object you can use.

###  License

MIT
