ecdh = require '../src/ecdh'
{ equal: eq } = ok = require 'assert'

describe 'ecdh', ->
  it 'works', ->
    pubkey = new Buffer '03a34b99f22c790c4e36b2b3c2c35a36db06226e41c692fc82b8b56ac1c540c5bd', 'hex'
    privkey = new Buffer 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'hex'
    for i in [1..5]
      pt = 'hello'+i
      eq pt, ecdh.decrypt privkey, ecdh.encrypt pubkey, pt
