#
# in the simplest case tagz generates html using a syntax which safely mixes
# in to any object
#

require 'tagz'
include Tagz.globally

class GiraffeModel
  def link
    a_(:href => "/giraffe/neck/42"){ "whack!" }
  end
end

puts GiraffeModel.new.link
