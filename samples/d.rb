#
# tagz.rb doesn't cramp your style, allowing even invalid html to be
# generated.  note the use of the 'tagz' method, which can be used both to
# capture output and to append content to the top of the stack.
#

require 'tagz'
include Tagz.globally

def header
  tagz{
    html_
      body_(:class => 'ninja-like', :id => 'giraffe-slayer')

      __ "<!-- this is the header -->"
  }
end

def footer
  tagz{
    __ "<!-- this is the footer -->"

      _body
    _html
  }
end

puts header, footer
