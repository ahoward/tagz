#
# tagz.rb allows a safer method of mixin which requires any tagz methods to be
# insider a tagz block - tagz generating methods outside a tagz block with
# raise an error if tagz is included this way.  also notice that the error is
# reported from where it was raised - not from the bowels of the the tagz.rb
# lib.
#

require 'tagz'
include Tagz

puts tagz{
 html_{ 'works only in here' }
}

begin
  html_{ 'not out here' }
rescue Object => e
  p :backtrace => e.backtrace
end

