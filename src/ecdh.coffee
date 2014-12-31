crypto = require 'crypto'
BigInt = require 'bigi'
{ Point, getCurveByName } = require 'ecurve'
{ reader, sha256, sha512, hmac, rand, rand_key, get_pub, buff_eq } = require './util'

VERSION = 1
MAGIC_BYTES = new Buffer [ 0x09, 0x43, 0x3d, 0x07, VERSION ]

PUBKEY_SIZE = 33
CHECKSUM_SIZE = 32

# Create ECDH encrypter/decrypter for the provided curve and cipher
create_ecdh = ({ curve_name, cipher_algo, key_size, iv_size }) ->
  curve = getCurveByName curve_name

  # Derive shared secret of 512 bits
  shared_secret = (d, Q) ->
    d = BigInt.fromBuffer d       if Buffer.isBuffer d
    Q = Point.decodeFrom curve, Q if Buffer.isBuffer Q

    sha512 Q.multiply(d).affineX.toBuffer()

  # Encrypt the plain text `msg` for `pubkey`
  encrypt: (pubkey, msg) ->
    eph    = rand_key curve, pubkey, msg
    eph_p  = get_pub curve, eph
    secret = shared_secret eph, pubkey
    iv     = sha256(eph_p)[0...iv_size]

    cipher = crypto.createCipheriv cipher_algo, secret[0...key_size], iv
    cipher.setAutoPadding true
    ct = cipher.update msg
    ct = Buffer.concat [ ct, cipher.final() ]

    checksum = hmac secret[key_size...], iv, ct
    Buffer.concat [ MAGIC_BYTES, eph_p, checksum, ct ]

  # Decrypt the ciphertext `enc` with `privkey`
  decrypt: (privkey, enc) ->
    read = reader enc
    unless buff_eq MAGIC_BYTES, read(MAGIC_BYTES.length)
      throw new Error 'Invalid magic bytes'

    pubkey   = read(PUBKEY_SIZE)
    checksum = read(CHECKSUM_SIZE)
    ct       = read()
    secret   = shared_secret privkey, pubkey
    iv       = sha256(pubkey)[0...iv_size]

    unless buff_eq checksum, hmac secret[key_size...], iv, ct
      throw new Error 'Invalid checksum'

    cipher = crypto.createDecipheriv cipher_algo, secret[0...key_size], iv
    cipher.setAutoPadding true
    msg = cipher.update ct
    Buffer.concat [ msg, cipher.final() ]

module.exports = create_ecdh

# Export default methods for secp256k1/AES-256-CBC directly on module.exports
for k, v of (create_ecdh curve_name: 'secp256k1', cipher_algo: 'AES-128-CBC', key_size: 16, iv_size: 16)
  module.exports[k] = v
