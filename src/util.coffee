BigInt = require 'bigi'
{ createHash, createHmac } = require 'crypto'
{ randomBuffer } = require 'secure-random'

# Buffer reader, consumes bytes as they're being read
reader = (buff, pos=0) -> (len) ->
  if len? then buff[pos...(pos+=len)]
  else buff[pos..]

# SHA256 convenience wrapper
sha256 = (d) -> createHash('sha256').update(d).digest()

# SHA512 convenience wrapper
sha512 = (d) -> createHash('sha512').update(d).digest()

# SHA256 HMAC convenience wrapper
hmac = (key, data...) ->
  h = createHmac 'sha256', key
  h.update d for d in data
  h.digest()

# Create 32 random bytes based on CSPRNG and user-provided entropy
rand = (entropy...) -> hmac randomBuffer(32), entropy...

# Create random private key
rand_key = (curve, entropy...) -> BigInt.fromBuffer(rand entropy...).mod(curve.n)

# Get the matching public key of a private key
get_pub = (curve, privkey) -> curve.G.multiply(privkey).getEncoded(true)

# Checks if two buffers are equal
buff_eq = (a, b) -> a.toString('hex') is b.toString('hex')

module.exports = { reader, sha256, sha512, hmac, rand, rand_key, get_pub, buff_eq }
