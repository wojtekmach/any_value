# Sometimes, especially when working with JSON APIs,
# when testing I found myself wanting to test the "shape" of data and only some particular elements, rather than either:
#
# - test everything - which is tricky with things like auto_increment primary keys, created_at fields etc
# - test only subset of data - do stuff like: `JSON(response.body).map { |h| h['name'] }.should == ['Item 1', 'Item 2']
#
# Here, I want to try something different. See:
# `test_why_someone_would_ever_use_it`

require "any_value/version"
require "delegate"
require "set"
require "time"
require "date"
require "uri"

module AnyValue
  class Anything
    def initialize(*args)
      @args = args
    end

    def ==(*)
      true
    end

    def inspect
      "#<%s>" % self.class.name.sub("Anything::", "")
    end

    def ^(other)
      Composite.new(self, other)
    end

    def to_ary
      self
    end

    def to_str
      self
    end
  end
  def anything
    Anything.new
  end

  class Composite < SimpleDelegator
    def initialize(left, right)
      super(left)
      @right = right
    end

    def ==(o)
      __getobj__.==(o) && @right.==(o)
    end

    def ^(other)
      Composite.new(self, other)
    end

    def inspect
      "#<Composite #{__getobj__.inspect} #{@right.inspect}>"
    end
  end

  class AnyInteger < Anything
    def ==(o)
      o.is_a?(Integer)
    end
  end
  def any_integer
    AnyInteger.new
  end

  class AnyNumber < Anything
    def ==(o)
      o.is_a?(Numeric)
    end
  end
  def any_number
    AnyNumber.new
  end

  class EvenNumber < AnyNumber
    def ==(o)
      super && o.even?
    end
  end
  def even_number
    EvenNumber.new
  end

  class OddNumber < AnyNumber
    def ==(o)
      super && o.odd?
    end
  end
  def odd_number
    OddNumber.new
  end

  class AnyString < Anything
    def ==(o)
      o.is_a?(String)
    end

    def to_str
      self
    end
  end
  def any_string
    AnyString.new
  end

  class OneOf < Anything
    def initialize(*values)
      super
      @values = values
    end

    def ==(o)
      @values.include?(o)
    end

    def inspect
      "#<OneOf #{@values.map(&:inspect).join(" ")}>"
    end
  end
  def one_of(*values)
    OneOf.new(*values)
  end

  class StringOfLength < AnyString
    def initialize(expected_length)
      super
      @expected_length = expected_length
    end

    def ==(o)
      super && o.length == @expected_length 
    end
    
    def inspect
      "#<StringOfLength #@expected_length>"
    end
  end
  def string_of_length(expected_length)
    StringOfLength.new(expected_length)
  end

  class StringMatching < AnyString
    def initialize(pattern)
      super
      @pattern = pattern
    end

    def ==(o)
      super && o =~ @pattern
    end

    def inspect
      "#<StringMatching #@pattern>"
    end
  end
  def string_matching(pattern)
    StringMatching.new(pattern)
  end

  # It's the same as:
  #
  # sorted_array = array_of(increasing)
  class SortedArray < Anything
    def ==(o)
      o == o.sort
    end

    def to_ary
      self
    end
  end
  def sorted_array
    SortedArray.new
  end

  class ArrayOf < Anything
    def initialize(element)
      unless element.is_a?(Anything)
        raise ArgumentError, "invalid argument: #{element.inspect}" 
      end

      super
      @element = element
    end

    def ==(o)
      o.all? { |x| x == @element }
    end

    def inspect
      "#<ArrayOf #{@element.inspect}>"
    end
  end
  def array_of(element)
    ArrayOf.new(element)
  end

  class AnyUnique < Anything
    def initialize
      @seen = Set.new
    end
    def ==(o)
      if @seen.include?(o)
        false
      else
        @seen << o
        true
      end
    end
  end
  def any_unique
    @_any_unique ||= AnyUnique.new
  end

  class Increasing < Anything
    def initialize
      @last = nil
      @for_inspect = nil
    end

    def ==(o)
      @for_inspect = @last
      if @last
        result = o > @last
        @last = o
        result
      else
        @last = o
        super
      end
    end

    def inspect
      "#<Increasing last=#{@for_inspect.inspect}>"
    end
  end
  def increasing
    @_increasing ||= Increasing.new
  end

  class UpcaseString < AnyString
    def ==(o)
      super && o.upcase == o
    end
  end
  def upcase_string
    UpcaseString.new
  end

  class AnyTime < Anything
    def ==(o)
      o.is_a?(Time)
    end
  end
  def any_time
    AnyTime.new
  end

  class AnyTimeString < Anything
    def ==(o)
      Time.parse(o)
      true
    rescue ArgumentError
      false
    end
  end
  def any_time_string
    AnyTimeString.new
  end

  class AnyDate < Anything
    def ==(o)
      o.is_a?(Date)
    end
  end
  def any_date
    AnyDate.new
  end

  class AnyDateString < Anything
    def ==(o)
      Date.parse(o)
      true
    rescue ArgumentError
      false
    end
  end
  def any_date_string
    AnyDateString.new
  end

  class AnyDateTimeString < Anything
    def ==(o)
      DateTime.parse(o)
      true
    rescue ArgumentError
      false
    end
  end
  def any_datetime_string
    AnyDateTimeString.new
  end

  class AnyHTTPURI < Anything
    def ==(o)
      uri = URI(o)
      uri.is_a?(URI::HTTP)
    end
  end
  def any_http_uri
    AnyHTTPURI.new
  end
end
