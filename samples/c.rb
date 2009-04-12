#
# once you've learned to generate html using tagz you're primed to generate
# xml too
#

require 'tagz'
include Tagz.globally

doc =
  xml_{
    giraffe_{ 'large' }
    ninja_{ 'small' }
  }

puts doc
