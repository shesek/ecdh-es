# ecdh-es
Elliptic Curve Diffie-Hellman with ephemeral-static keys implementation for NodeJS

### Install

    npm install --save ecdh-es

### Use
    var ecdh = require('ecdh-es')
      , pubkey = new Buffer('03a34b99f22c790c4e36b2b3c2c35a36db06226e41c692fc82b8b56ac1c540c5bd', 'hex')
      , privkey = new Buffer('e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'hex')

    var encrypted = ecdh.encrypt(privkey, 'Hello, world!') // -> Buffer
    var decrypted = ecdh.decrypt(pubkey, encrypted) // -> Buffer
    // (use toString() to convert back to string message)

    // Uses the secp256k1 curve and AES-256-CBC cipher by default,
    // but can be overridden as follows:
    var ecdh = require('ecdh-es')('secp192k1', 'AES-256-CTR')

###  License

MIT
