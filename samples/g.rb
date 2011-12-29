# -*- encoding : utf-8 -*-
# tagz gives you low-level control of the output and makes even dashersized
# xml tagz easy enough to work with
#

require 'tagz'
include Tagz.globally

xml =
  root_{
    tagz__('foo-bar', :key => 'foo&bar'){ 'content' }

    tagz__('bar-foo')
    tagz.concat 'content'
    tagz.concat tagz.escape('foo&bar')
    __tagz('bar-foo')
  }

puts xml

