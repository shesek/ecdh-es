crypto = require 'crypto'
BigInt = require 'bigi'
{ Point, getCurveByName } = require 'ecurve'
{ reader, sha512, hmac, rand, rand_key, get_pub, buff_eq } = require './util'

VERSION = 1
MAGIC_BYTES = new Buffer [ 0x09, 0x43, 0x3d, 0x07, VERSION ]

PUBKEY_SIZE = 33
CHECKSUM_SIZE = 32
AES_IV_SIZE = 16

# Create ECDH encrypter/decrypter for the provided curve and cipher
create_ecdh = (curve_name, cipher_algo) ->
  curve = getCurveByName curve_name

  # Derive shared secret of 512 bits
  shared_secret = (d, Q) ->
    d = BigInt.fromBuffer d       if Buffer.isBuffer d
    Q = Point.decodeFrom curve, Q if Buffer.isBuffer Q

    sha512 Q.multiply(d).affineX.toBuffer()

  # Encrypt the plain text `msg` for `pubkey`
  encrypt: (pubkey, msg) ->
    eph    = rand_key curve, pubkey, msg
    secret = shared_secret eph, pubkey
    iv     = rand(secret, msg)[0...AES_IV_SIZE]

    cipher = crypto.createCipheriv cipher_algo, secret[0...32], iv
    cipher.setAutoPadding true
    ct = cipher.update msg
    ct = Buffer.concat [ ct, cipher.final() ]

    checksum = hmac secret[32...64], iv, ct
    Buffer.concat [ MAGIC_BYTES, get_pub(curve, eph), checksum, iv, ct ]

  # Decrypt the ciphertext `enc` with `privkey`
  decrypt: (privkey, enc) ->
    read = reader enc
    unless buff_eq MAGIC_BYTES, read(MAGIC_BYTES.length)
      throw new Error 'Invalid magic bytes'

    secret   = shared_secret privkey, read(PUBKEY_SIZE)
    checksum = read(CHECKSUM_SIZE)
    iv       = read(AES_IV_SIZE)
    ct       = read()

    unless buff_eq checksum, hmac secret[32...64], iv, ct
      throw new Error 'Invalid checksum'

    cipher = crypto.createDecipheriv cipher_algo, secret[0...32], iv
    cipher.setAutoPadding true
    msg = cipher.update ct
    Buffer.concat [ msg, cipher.final() ]

module.exports = create_ecdh

# Export default methods for secp256k1/AES-256-CBC directly on module.exports
for k, v of create_ecdh 'secp256k1', 'AES-256-CBC'
  module.exports[k] = v
