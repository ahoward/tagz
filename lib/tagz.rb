unless defined? Tagz

  module Tagz
    unless defined?(Tagz::VERSION)
      Tagz::VERSION = [
        Tagz::VERSION_MAJOR = 5,
        Tagz::VERSION_MINOR = 0,
        Tagz::VERSION_TEENY = 1 
      ].join('.')
      def Tagz.version() Tagz::VERSION end
    end

  private

  # open_tag
  #
    def tagz__ name, *argv, &block
      options = argv.last.is_a?(Hash) ? argv.pop : {}
      content = argv

      unless options.empty?
        attributes = ' ' << 
          options.map do |key, value|
            key = XChar.escape key.to_s
            value = XChar.escape value.to_s
            if value =~ %r/"/
              raise ArgumentError, value if value =~ %r/'/
              value = "'#{ value }'"
            else
              raise ArgumentError, value if value =~ %r/"/
              value = "\"#{ value }\""
            end
            [key, value].join('=')
          end.join(' ')
      else
        attributes = ''
      end

      tagz.concat "<#{ name }#{ attributes }>"

      if content.empty?
        if block
          size = tagz.size
          value = block.call(tagz)

          if value.nil?
            unless(tagz.size > size)
              tagz[-1] = "/>"
            else
              tagz.concat "</#{ name }>"
            end
          else
            tagz << value.to_s unless(tagz.size > size)
            tagz.concat "</#{ name }>"
          end

        end
      else
        tagz << content.join
        if block
          size = tagz.size
          value = block.call(tagz)
          tagz << value.to_s unless(tagz.size > size)
        end
        tagz.concat "</#{ name }>"
      end

      tagz
    end

  # close_tag
  #
    def __tagz tag, *a, &b
      tagz.concat "</#{ tag }>"
    end

  # access tagz doc and enclose tagz operations
  #
    def tagz document = nil, &block
      @tagz ||= nil ## shut wornings up
      previous = @tagz

      if block
        @tagz ||= (Document.for(document) || Document.new)
        begin
          size = @tagz.size
          value = instance_eval(&block)
          @tagz << value unless(@tagz.size > size)
          @tagz
        ensure
          @tagz = previous
        end
      else
        document ? Document.for(document) : @tagz
      end
    end

  # catch special tagz methods
  #
    def method_missing m, *a, &b
      strategy =
        case m.to_s
          when %r/^(.*[^_])_(!)?$/o
            :open_tag
          when %r/^_([^_].*)$/o
            :close_tag
          when 'e'
            :element
          when '__', '___'
            :puts
          else
            nil
        end

      if(strategy.nil? or (tagz.nil? and not Globally===self))
        begin
          super
        ensure
          $!.set_backtrace caller(skip=1) if $!
        end
      end
      
      case strategy
        when :open_tag
          m, bang = $1, $2
          b ||= lambda{} if bang
          tagz{ tagz__(m, *a, &b) }
        when :close_tag
          m = $1
          tagz{ __tagz(m, *a, &b) }
        when :element
          Element.new(*a, &b)
        when :puts
          tagz do
            tagz.concat("\n")
            unless a.empty?
              tagz.concat(a.join)
              tagz.concat("\n")
            end
          end
      end
    end

    class Document < ::String
      def Document.for other
        Document === other ? other : Document.new(other.to_s)
      end

      def element
        Element.new(*a, &b)
      end
      alias_method 'e', 'element'

      def << string 
        case string
          when Document
            super string.to_s
          else
            super XChar.escape(string.to_s)
        end
        self
      end

      def escape(*strings)
        XChar.escape(strings.join)
      end
      alias_method 'h', 'escape'

      def puts string
        concat "#{ string }\n"
      end
      alias_method 'push', 'concat'
      alias_method 'write', 'concat'

      def document
        self
      end
      alias_method 'doc', 'document'

      def + other
        self.dup << other
      end

      def to_s
        self
      end

      def to_str
        self
      end
    end

    class Element < ::String
      def Element.attributes options
        unless options.empty?
          ' ' << 
            options.map do |key, value|
              key = XChar.escape key.to_s
              value = XChar.escape value.to_s
              if value =~ %r/"/
                raise ArgumentError, value if value =~ %r/'/
                value = "'#{ value }'"
              else
                raise ArgumentError, value if value =~ %r/"/
                value = "\"#{ value }\""
              end
              [key, value].join('=')
            end.join(' ')
        else
          ''
        end
      end

      attr 'name'

      def initialize name, *argv, &block
        options = {}
        content = []

        argv.each do |arg|
          case arg
            when Hash
              options.update arg
            else
              content.push arg
          end
        end

        content.push block.call if block
        content.compact!

        @name = name.to_s

        if content.empty?
          replace "<#{ @name }#{ Element.attributes options }>"
        else
          replace "<#{ @name }#{ Element.attributes options }>#{ content.join }</#{ name }>"
        end
      end
    end

    module XChar
    # http://intertwingly.net/stories/2004/04/14/i18n.html#CleaningWindows
    #
      CP1252 = {
        128 => 8364, # euro sign
        130 => 8218, # single low-9 quotation mark
        131 =>  402, # latin small letter f with hook
        132 => 8222, # double low-9 quotation mark
        133 => 8230, # horizontal ellipsis
        134 => 8224, # dagger
        135 => 8225, # double dagger
        136 =>  710, # modifier letter circumflex accent
        137 => 8240, # per mille sign
        138 =>  352, # latin capital letter s with caron
        139 => 8249, # single left-pointing angle quotation mark
        140 =>  338, # latin capital ligature oe
        142 =>  381, # latin capital letter z with caron
        145 => 8216, # left single quotation mark
        146 => 8217, # right single quotation mark
        147 => 8220, # left double quotation mark
        148 => 8221, # right double quotation mark
        149 => 8226, # bullet
        150 => 8211, # en dash
        151 => 8212, # em dash
        152 =>  732, # small tilde
        153 => 8482, # trade mark sign
        154 =>  353, # latin small letter s with caron
        155 => 8250, # single right-pointing angle quotation mark
        156 =>  339, # latin small ligature oe
        158 =>  382, # latin small letter z with caron
        159 =>  376} # latin capital letter y with diaeresis

    # http://www.w3.org/TR/REC-xml/#dt-chardata
    #
      PREDEFINED = {
        38 => '&amp;', # ampersand
        60 => '&lt;',  # left angle bracket
        62 => '&gt;'}  # right angle bracket

    # http://www.w3.org/TR/REC-xml/#charsets
    #
      VALID = [[0x9, 0xA, 0xD], (0x20..0xD7FF), (0xE000..0xFFFD), (0x10000..0x10FFFF)]

      def XChar.escape(string)
        string.unpack('U*').map{|n| xchr(n)}.join # ASCII, UTF-8
      rescue
        string.unpack('C*').map{|n| xchr(n)}.join # ISO-8859-1, WIN-1252
      end

      def XChar.xchr(n)
        (@xchr ||= {})[n] ||= ((
          n = XChar::CP1252[n] || n
          n = 42 unless XChar::VALID.find{|range| range.include? n}
          XChar::PREDEFINED[n] or (n<128 ? n.chr : "&##{n};")
        ))
      end
    end

    def Tagz.escapeHTML string
      XChar.escape(string)
    end

    module Globally; include Tagz; end
    def Tagz.globally
      Globally
    end

    module Privately; include Tagz; end
    def Tagz.privately
      Privately
    end

    %w( tagz tagz__ __tagz method_missing ).each{|m| module_function(m)}
  end

  def Tagz *argv, &block
    if argv.empty? and block.nil?
      ::Tagz
    else
      Tagz.tagz(*argv, &block)
    end
  end

  if defined?(Rails)
    ActionView::Base.send(:include, Tagz.globally)
    ActionController::Base.send(:include, Tagz)
  end

end
