unless defined? Tagz

# core tagz functions
#
  module Tagz
    def Tagz.version() '7.2.0' end

  private
    # access tagz doc and enclose tagz operations
    #
      def tagz document = nil, &block
        @tagz ||= nil ## shut wornings up
        previous = @tagz

        if block
          @tagz ||= (Tagz.document.for(document) || Tagz.document.new)
          begin
            size = @tagz.size
            value = instance_eval(&block)
            @tagz << value unless(@tagz.size > size)
            @tagz
          ensure
            @tagz = previous
          end
        else
          document ? Tagz.document.for(document) : @tagz
        end
      end

    # open_tag
    #
      def tagz__ name, *argv, &block
        options = argv.last.is_a?(Hash) ? argv.pop : {}
        content = argv

        unless options.empty?
          attributes = ' ' << 
            options.map do |key, value|
              key = Tagz.escape_attribute(key)
              value = Tagz.escape_attribute(value)
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

        tagz.push "<#{ name }#{ attributes }>"

        if content.empty?
          if block
            size = tagz.size
            value = block.call(tagz)

            if value.nil?
              unless(tagz.size > size)
                tagz[-1] = "/>"
              else
                tagz.push "</#{ name }>"
              end
            else
              tagz << value.to_s unless(tagz.size > size)
              tagz.push "</#{ name }>"
            end

          end
        else
          tagz << content.join
          if block
            size = tagz.size
            value = block.arity.abs >= 1 ? block.call(tagz) : block.call()
            tagz << value.to_s unless(tagz.size > size)
          end
          tagz.push "</#{ name }>"
        end

        tagz
      end

    # close_tag
    #
      def __tagz tag, *a, &b
        tagz.push "</#{ tag }>"
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

        if(strategy.nil? or (tagz.nil? and not Tagz.globally===self))
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
            Tagz.element.new(*a, &b)
          when :puts
            tagz do
              tagz.push("\n")
              unless a.empty?
                tagz.push(a.join)
                tagz.push("\n")
              end
            end
        end
      end
  end


# supporting code
#
  module Tagz
  # singleton_class access for ad-hoc method adding from inside namespace
  #
    def Tagz.singleton_class(&block)
      @singleton_class ||= (
        class << Tagz
          self
        end
      )
      block ? @singleton_class.module_eval(&block) : @singleton_class
    end

  # hide away our own shit to minimize namespace pollution
  #
    module Namespace
      namespace = self

      Tagz.singleton_class{
        define_method(:namespace){ |*args|
          if args.empty?
            namespace
          else
            namespace.const_get(args.first.to_sym)
          end
        }
      }

      class Document < ::String
        def Document.for other
          Document === other ? other : Document.new(other.to_s)
        end

        def element
          Tagz.element.new(*a, &b)
        end
        alias_method 'e', 'element'

        alias_method 'write', 'concat'
        alias_method 'push', 'concat'

        def << string 
          case string
            when Document
              super string.to_s
            else
              super Tagz.escape_content(string)
          end
          self
        end
        def concat string
          self << string
        end
        #alias_method 'concat', '<<'

        def escape(*strings)
          Tagz.xchar.escape(strings.join)
        end
        alias_method 'h', 'escape'

        def puts string
          write "#{ string }\n"
        end

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
      Tagz.singleton_class{ define_method(:document){ Tagz.namespace(:Document) } }

      class Element < ::String
        def Element.attributes options
          unless options.empty?
            ' ' << 
              options.map do |key, value|
                key = Tagz.escape_attribute(key)
                value = Tagz.escape_attribute(value)
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
      Tagz.singleton_class{ define_method(:element){ Tagz.namespace(:Element) } }

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
      Tagz.singleton_class{ define_method(:xchar){ Tagz.namespace(:XChar) } }

      NoEscapeProc = lambda{|*values| values.join}
      Tagz.singleton_class{ define_method(:no_escape_proc){ Tagz.namespace(:NoEscapeProc) } }

      EscapeProc = lambda{|*values| Tagz.xchar.escape(values.join)}
      Tagz.singleton_class{ define_method(:escape_proc){ Tagz.namespace(:EscapeProc) } }

      module Globally; include Tagz; end
      Tagz.singleton_class{ define_method(:globally){ Tagz.namespace(:Globally) } }

      module Privately; include Tagz; end
      Tagz.singleton_class{ define_method(:privately){ Tagz.namespace(:Privately) } }
    end
    remove_const(:Namespace)

  # escape utils
  #
    def Tagz.escapeHTML(*strings)
      Tagz.xchar.escape(strings.join)
    end
    def Tagz.escape(*strings)
      Tagz.xchar.escape(strings.join)
    end

  # support for configuring attribute escaping
  #
    def Tagz.escape_attribute!(*args, &block)
      previous = @escape_attribute if defined?(@escape_attribute)
      unless args.empty? and block.nil?
        value = block ? block : args.shift
        value = Tagz.escape_proc if value==true
        value = Tagz.no_escape_proc if(value==false or value==nil)
        @escape_attribute = value.to_proc
        return previous
      end
      @escape_attribute
    end
    def Tagz.escape_attributes!(*args, &block)
      Tagz.escape_attribute!(*args, &block)
    end
    def Tagz.escape_attribute(value)
      @escape_attribute.call(value.to_s)
    end

  # support for configuring content escaping
  #
    def Tagz.escape_content!(*args, &block)
      previous = @escape_content if defined?(@escape_content)
      unless args.empty? and block.nil?
        value = block ? block : args.shift
        value = Tagz.escape_proc if value==true
        value = Tagz.no_escape_proc if(value==false or value==nil)
        @escape_content = value.to_proc
        return previous
      end
      @escape_content
    end
    def Tagz.escape_contents!(*args, &block)
      Tagz.escape_content!(*args, &block)
    end
    def Tagz.escape_content(value)
      @escape_content.call(value.to_s)
    end

  # configure tagz escaping
  #
    def Tagz.escape!(options = {})
      options = {:attributes => options, :content => options} unless options.is_a?(Hash)
      escape_attributes = options[:attributes]||options['attributes']
      escape_content = options[:content]||options['content']
      Tagz.escape_attributes!(!!escape_attributes)
      Tagz.escape_content!(!!escape_content)
    end
    def Tagz.i_know_what_the_hell_i_am_doing!
      escape!(false)
    end
    def Tagz.i_do_not_know_what_the_hell_i_am_doing!
      escape!(true)
    end
    def Tagz.xml_mode!
      Tagz.escape!(
        :attributes => true,
        :content => true
      )
    end
    def Tagz.html_mode!
      Tagz.escape!(
        :attributes => true,
        :content => false
      )
    end

  # allow access to instance methods via module handle
  #
    %w( tagz tagz__ __tagz method_missing ).each{|m| module_function(m)}
  end

  def Tagz *argv, &block
    (argv.empty? and block.nil?) ? ::Tagz : Tagz.tagz(*argv, &block)
  end

  if defined?(Rails)
    _=ActionView,ActionView::Base,ActionController,ActionController::Base
    ActionView::Base.send(:include, Tagz.globally)
    ActionController::Base.send(:include, Tagz)
  end

  Tagz.html_mode!
end
