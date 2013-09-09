# -*- encoding : utf-8 -*-
#! /usr/bin/env ruby

require 'test/unit'

$VERBOSE = 2
STDOUT.sync = true
$:.unshift 'lib'
$:.unshift '../lib'
$:.unshift '.'

require 'tagz'

class TagzTest < Test::Unit::TestCase
  include Tagz

  class ::String
    Equal = instance_method '=='
    remove_method '=='
    def == other
      Equal.bind(self.delete(' ')).call other.to_s.delete(' ')
    end
  end

  def test_000
    expected = '<foo  ></foo>'
    actual = tagz{ 
      foo_
      _foo
    }
    assert_equal expected, actual
  end

  def test_010
    expected = '<foo  ><bar  ></bar></foo>'
    actual = tagz{ 
      foo_
        bar_
        _bar
      _foo
    }
    assert_equal expected, actual
  end

  def test_020
    expected = '<foo  ><bar  /></foo>'
    actual = tagz{ 
      foo_
        bar_{}
      _foo
    }
    assert_equal expected, actual
  end

  def test_030
    expected = '<foo  ><bar /></foo>'
    actual = tagz{ 
      foo_{
        bar_{}
      }
    }
    assert_equal expected, actual
  end

  def test_040
    expected = '<foo  >bar</foo>'
    actual = tagz{ 
      foo_{ 'bar' }
    }
    assert_equal expected, actual
  end

  def test_050
    expected = '<foo  ><bar  >foobar</bar></foo>'
    actual = tagz{ 
      foo_{ 
        bar_{ 'foobar' }
      }
    }
    assert_equal expected, actual
  end

  def test_060
    expected = '<foo key="value"  ><bar a="b"  >foobar</bar></foo>'
    actual = tagz{ 
      foo_('key' => 'value'){ 
        bar_(:a => :b){ 'foobar' }
      }
    }
    assert_equal expected, actual
  end

  def test_070
    expected = '<foo  /><bar  />'
    actual = tagz{ 
      foo_{} + bar_{}
    }
    assert_equal expected, actual
  end

=begin
  def test_080
    assert_raises(Tagz::NotOpen) do
      foo_{ _bar }
    end
  end
  def test_090
    assert_raises(Tagz::NotOpen) do
      _foo
    end
  end
  def test_100
    assert_nothing_raised do
      foo_
      _foo
    end
  end
=end

  def test_110
    expected = '<foo  ><bar  >foobar</bar></foo>'
    actual = tagz{ 
      foo_{ 
        bar_{ 'foobar' }
        'this content is ignored because the block added content'
      }
    }
    assert_equal expected, actual
  end

  def test_120
    expected = '<foo  ><bar  >foobar</bar><baz  >barfoo</baz></foo>'
    actual = tagz{ 
      foo_{ 
        bar_{ 'foobar' }
        baz_{ 'barfoo' }
      }
    }
    assert_equal expected, actual
  end

  def test_121
    expected = '<foo  ><bar  >foobar</bar><baz  >barfoo</baz></foo>'
    actual = tagz{ 
      foo_{ 
        bar_{ 'foobar' }
        baz_{ 'barfoo' }
      }
    }
    assert_equal expected, actual
  end

  def test_130
    expected = '<foo  >a<bar  >foobar</bar>b<baz  >barfoo</baz></foo>'
    actual = tagz{ 
      foo_{ |t|
        t << 'a'
        bar_{ 'foobar' }
        t << 'b'
        baz_{ 'barfoo' }
      }
    }
    assert_equal expected, actual
  end

  def test_140
    expected = '<foo  ><bar  >baz</bar></foo>'
    actual = tagz{ 
      foo_{
        bar_ << 'baz'
        _bar
      }
    }
    assert_equal expected, actual
  end

  def test_150
    expected = '<foo  ><bar  >bar<baz  >baz</baz></bar></foo>'
    actual = tagz{ 
      foo_{
        bar_ << 'bar'
          tag = baz_
          tag << 'baz'
          _baz
        _bar
      }
    }
    assert_equal expected, actual
  end

  def test_160
    expected = '<foo  >a<bar  >b</bar></foo>'
    actual = tagz{ 
      foo_{ |foo|
        foo << 'a'
        bar_{ |bar|
          bar << 'b'
        }
      }
    }
    assert_equal expected, actual
  end

  def test_170
    expected = '<html  ><body  ><ul  ><li  >a</li><li  >b</li><li  >c</li></ul></body></html>'
    @list = %w( a b c )
    actual = tagz{ 
      html_{
        body_{
          ul_{
            @list.each{|elem| li_{ elem } }
          }
        }
      }
    }
    assert_equal expected, actual
  end

  def test_180
    expected = '<html  ><body  >42</body></html>'
    actual = tagz{ 
      html_{
        b = body_
          b << 42
        _body
      }
    }
    assert_equal expected, actual
  end

  def test_190
    expected = '<html  ><body  >42</body></html>'
    actual = tagz{ 
      html_{
        body_
          tagz << 42 ### tagz is always the current tag!
        _body
      }
    }
    assert_equal expected, actual
  end

  def test_200
    expected = '<html  ><body  >42</body></html>'
    actual = tagz{ 
      html_{
        body_{
          tagz << 42 ### tagz is always the current tag!
        }
      }
    }
    assert_equal expected, actual
  end

  def test_210
    expected = '<html  ><body  >42</body></html>'
    actual = tagz{ 
      html_{
        body_{ |body|
          body << 42
        }
      }
    }
    assert_equal expected, actual
  end

=begin
  def test_220
    expected = '<html  ><body  >42</body></html>'
    actual = tagz{ 
      'html'.tag do
       'body'.tag do
          42
        end
      end
    }
    assert_equal expected, actual
  end
=end

  def test_230
    expected = '<html  ><body  ><div k="v"  >content</div></body></html>'
    actual = tagz{ 
      html_{
        body_{
          div_(:k => :v){ "content" }
        }
      }
    }
    assert_equal expected, actual
  end

  def test_240
    expected = '<html  ><body  ><div k="v"  >content</div></body></html>'
    actual = tagz{ 
      html_{
        body_{
          div_ "content", :k => :v
        }
      }
    }
    assert_equal expected, actual
  end

  def test_241
    expected = '<html  ><body  ><div k="v"  >content</div></div></body></html>'
    actual = tagz{ 
      html_{
        body_{
          div_ "content", :k => :v 
          _div
        }
      }
    }
    assert_equal expected, actual
  end

  def test_250
    expected = '<html  ><body  ><div k="v"  >content and more content</div></body></html>'
    actual = tagz{ 
      html_{
        body_{
          div_("content", :k => :v){ ' and more content' }
        }
      }
    }
    assert_equal expected, actual
  end

  def test_260
    expected = '<html  ><body  ><div k="v"  >content</div></body></html>'
    actual = tagz{ 
      html_{
        body_{
          div_ :k => :v 
          tagz << "content"
          _div
        }
      }
    }
    assert_equal expected, actual
  end

  def test_270
    expected = '<html  ><body  ><div k="v"  >content</div></body></html>'
    actual = tagz{ 
      html_{
        body_{
          div_ :k => :v 
          tagz << "content"
          _div
        }
      }
    }
    assert_equal expected, actual
  end

  def test_280
    expected = 'content'
    actual = tagz{ 
      tagz << "content"
    }
    assert_equal expected, actual
  end

  def test_290
    expected = 'foobar'
    actual = tagz{ 
      tagz {
        tagz << 'foo' << 'bar'
      }
    }
    assert_equal expected, actual
  end

=begin
  def test_300
    expected = 'foobar'
    actual = tagz{ 
      tagz{ tagz 'foo', 'bar' }
    }
    assert_equal expected, actual
  end
=end

  def test_310
    expected = '<html  ><body  ><div k="v"  >foobar</div></body></html>'
    actual = tagz{ 
      html_{
        body_{
          div_! "foo", "bar", :k => :v 
        }
      }
    }
    assert_equal expected, actual
  end

  def test_320
    expected = '<html  ><body  ><a href="a"  >a</a><span  >|</span><a href="b"  >b</a><span  >|</span><a href="c"  >c</a></body></html>'
    links = %w( a b c )
    actual = tagz{ 
      html_{
        body_{
          tagz.write links.map{|link| e(:a, :href => link){ link }}.join(e(:span){ '|' })
        }
      }
    }
    assert_equal expected, actual
  end

  def test_330
    expected = '<a  ><b  ><c  >'
    actual = tagz{ 
      tagz {
        a_
        b_
        c_
      }
    }
    assert_equal expected, actual
  end

  def test_340
    expected = '<a  ><b  ><c  ></a>'
    actual = tagz{ 
      a_ {
        b_
        c_
      }
    }
    assert_equal expected, actual
  end

  def test_350
    expected = '<a  ><b  ><c  >content</c></a>'
    actual = tagz{ 
      a_ {
        b_
        c_ "content"
      }
    }
    assert_equal expected, actual
  end

  def test_360
    expected = '<a  ><b  >content</b><c  ><d  >more content</d></a>'
    actual = tagz{ 
      a_ {
        b_ "content"
        c_
        d_ "more content"
      }
    }
    assert_equal expected, actual
  end

=begin
  def test_370
    expected = 'ab'
    actual = tagz{ 
      re = 'a'
      re << tagz{'b'}
      re
    }
    assert_equal expected, actual
  end
=end

  def test_380
    expected = 'ab'
    actual = tagz{ 
      tagz{ 'a' } + tagz{ 'b' } 
    }
    assert_equal expected, actual
  end

  def test_390
    expected = '<div class="bar&amp;foo&gt;">foo&amp;bar&gt;</div>'
    actual = tagz{ div_(:class => 'bar&foo>'){ 'foo&bar>' } }
    assert_equal expected, actual

    expected = %|<div class="bar&amp;foo&gt;">#{ expected }</div>|
    actual = tagz{ div_(:class => 'bar&foo>'){ actual } }
    assert_equal expected, actual
  end

  def test_400
    expected = '<div><span>foo&amp;bar</span></div>'
    actual = tagz{ div_{ span_{ 'foo&bar' } } }
    assert_equal expected, actual
  end

  def test_410
    expected = '<div>false</div>'
    actual = tagz{ div_{ false } }
    assert_equal expected, actual
  end

  def test_420
    expected = "<div>\n<span>foobar</span>\nfoobar\n</div>"
    actual = tagz{ div_{ __; span_{ :foobar }; ___('foobar'); } }
    assert_equal expected, actual
  end

  def test_430
    c = Class.new{
      include Tagz.globally
      def foobar() div_{ 'foobar' } end
    }.new

    actual=nil
    assert_nothing_raised{ actual=c.foobar }
    expected = '<div>foobar</div>'
    assert_equal expected, actual

=begin
    e = nil
    assert_raises(NoMethodError){ begin; c.missing; ensure; e=$!; end }
    assert e
    messages = e.backtrace.map{|line| line.split(%r/:/, 3).last}
    assert messages.all?{|message| message !~ /tagz/}
=end
  end

  def test_440
    c = Class.new{
      include Tagz.privately
      def foobar() tagz{ div_{ 'foobar' } } end
      def barfoo() div_{ 'barfoo' } end
    }.new

    actual=nil
    assert_nothing_raised{ actual=c.foobar }
    expected = '<div>foobar</div>'
    assert_equal expected, actual

    assert_raises(NoMethodError){ c.barfoo }
  end

  def test_450
    c = Class.new{
      include Tagz.globally
      def a() tagz{ a_{ b(tagz); nil } } end
      def b(doc=nil) tagz(doc){ b_{ 'content' } } end
    }.new

    actual=nil
    assert_nothing_raised{ actual=c.a }
    expected = '<a><b>content</b></a>'
    assert_equal expected, actual
    assert_nothing_raised{ c.b }
  end

  def test_460
    c = Class.new{
      include Tagz.globally
      def a
        div_( 'a>b' => 'a>b' ){ 'content' }
      end
    }.new

    actual = nil
    assert_nothing_raised{ actual=c.a}
    expected = %(<div a&gt;b="a&gt;b">content</div>)
    assert_equal expected, actual

    Tagz.escape_keys!(false) do
      Tagz.escape_values!(false) do
        actual = nil
        assert_nothing_raised{ actual=c.a}
        expected = %(<div a>b="a>b">content</div>)
        assert_equal expected, actual
      end
    end

    upcased = lambda{|value| value.to_s.upcase}
    Tagz.escape_key!(upcased) do
      Tagz.escape_value!(upcased) do
        actual = nil
        assert_nothing_raised{ actual=c.a}
        expected = %(<div A>B="A>B">content</div>)
        assert_equal expected, actual
      end
    end
  end

  def test_470
    c = Class.new{
      include Tagz.globally
      def a
        div_( ){ 'a>b' }
      end
    }.new

    actual = nil
    assert_nothing_raised{ actual=c.a}
    expected = %(<div>a&gt;b</div>)
    assert_equal expected, actual

    original = Tagz.escape_content!(true)
    assert original
    actual = nil
    assert_nothing_raised{ actual=c.a}
    expected = %(<div>a&gt;b</div>)
    assert_equal expected, actual

    upcased = Tagz.escape_content!(lambda{|value| original.call(value).upcase})
    assert upcased
    actual = nil
    assert_nothing_raised{ actual=c.a}
    expected = %(<div>A&GT;B</div>)
    assert_equal expected, actual

    Tagz.escape_content!(original)
    actual = nil
    assert_nothing_raised{ actual=c.a}
    expected = %(<div>a&gt;b</div>)
    assert_equal expected, actual
  ensure
    Tagz.escape_content!(original)
  end

  def test_480
    c = Class.new{
      include Tagz.globally
      def a
        div_( 'a>b' => '<>'){ 'a>b' }
      end
    }.new

    Tagz.i_know_what_the_hell_i_am_doing!
    actual = nil
    assert_nothing_raised{ actual=c.a}
    expected = %(<div a>b="<>">a>b</div>)
    assert_equal expected, actual
  ensure
    Tagz.i_do_not_know_what_the_hell_i_am_doing!
  end

  def test_490
    c = Class.new{
      include Tagz.globally
      def a
        div_{
          __
          tagz.concat 'a>b'
          __
          tagz.write 'c>d'
          __
          tagz << 'e>f'
          __
          tagz.push 'g>h'
          __
          tagz.raw '<tag />'
        }
      end
    }.new

    actual = nil
    assert_nothing_raised{ actual=c.a}
    expected = "<div>\na&gt;b\nc>d\ne&gt;f\ng>h\n<tag /></div>"
    assert_equal expected, actual
  end

  def test_500
    expected = actual = nil
    Module.new do
      before = constants
      include Tagz
      after = constants
      expected = []
      actual = after - before
    end
    assert_equal expected, actual
  end

  def test_510
    expected = actual = nil
    Module.new do
      before = constants
      include Tagz.globally
      after = constants
      expected = []
      actual = after - before
    end
    assert_equal expected, actual
  end

  def test_520
    expected = actual = nil
    Module.new do
      before = constants
      include Tagz.privately
      after = constants
      expected = []
      actual = after - before
    end
    assert_equal expected, actual
  end

  def test_530
    assert_nothing_raised{
      code = <<-__
        class C
          Element=NoEscape=Document=XChar=Privately=Escape=Globally=42
          include Tagz.globally
          def a() tagz{ 42 } end
        end
        C.new.a()
      __
      assert_nothing_raised do
        assert eval(code), '42'
      end
    }
  end

  def test_540
    expected = '<foo checked><bar selected="selected">foobar</bar></foo>'
    actual = tagz{
      foo_('checked' => true){
        bar_(:selected => :selected){ 'foobar' }
      }
    }
    assert_equal expected, actual
  end


  def test_550
    assert_nothing_raised{
      Tagz{ div_(:title => "foo' bar\""){ "foobar" } }
    }
  end

  def test_600
    value = '&lt;&gt;'
    html_safe = Tagz.html_safe(value)
    assert_equal(value, html_safe)
    assert_equal(false, value.respond_to?(:html_safe?))
    assert_equal(false, value.respond_to?(:html_safe))
    assert_equal(true, html_safe.respond_to?(:html_safe?))
    assert_equal(true, html_safe.respond_to?(:html_safe))
  end

  def test_610
    value = Tagz.html_safe.new('foobar')
    html_safe = Tagz.html_safe(value)
    assert_equal value.object_id, html_safe.object_id
  end

  def test_620
    expected = '<div>&#215;</div>'
    actual = Tagz{ div_{ Tagz.html_safe('&#215;') }  }
    assert_equal expected, actual
  end
end
