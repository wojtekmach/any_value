require "test_helper"
require "securerandom"

class AnythingTest < Minitest::Test
  include Anything

  def test_why_someone_would_ever_use_it
    people = [
      [SecureRandom.uuid, Time.now, "Alice"],
      [SecureRandom.uuid, Time.now + 10, "Bob"],
    ]

    uuid = any_unique ^ string_of_length(36)

    assert_equal [
      [uuid, any_time, "Alice"],
      [uuid, any_time, "Bob"],
    ], people
  end

  def test_anything
    assert_equal anything, 42
    assert_equal anything, anything

    assert_equal anything, nil
    skip
    assert_equal nil, anything
  end

  def test_any_integer
    assert_equal any_integer, 42

    refute_equal any_integer, "foo"
    refute_equal any_integer, 1.0
    refute_equal "foo", any_integer
  end

  def test_any_number
    assert_equal any_number, 42
    assert_equal any_number, 42.0

    refute_equal "foo", any_number
  end

  def test_any_string
    assert_equal any_string, "foo"

    refute_equal any_string, 42
  end

  def test_one_of
    animals = one_of("dog", "cat")

    assert_equal animals, "dog"
    refute_equal animals, "chair"
  end

  def test_string_of_length
    assert_equal string_of_length(3), "foo"

    refute_equal string_of_length(5), "foo"
  end

  def test_string_matching
    x = string_matching(/foo/)
    assert_equal x, "foo"
    assert_equal x, "foo foo"

    refute_equal x, "bar"
  end

  def test_upcase_string
    assert_equal upcase_string, "FOO"

    refute_equal upcase_string, "Foo"
  end

  def test_composition
    three_letter_upcase = string_of_length(3) ^ upcase_string

    assert_equal three_letter_upcase, "FOO"
    refute_equal three_letter_upcase, "FOOFOO"
    refute_equal three_letter_upcase, "foo"
  end

  def test_composition_composition
    starts_with_n = Class.new(AnyString) {
      def ==(o)
        o.start_with?("n") || o.start_with?("N")
      end
    }.new

    acronym = string_of_length(3) ^ upcase_string ^ starts_with_n

    assert_equal acronym, "NBA"
    assert_equal acronym, "NSA"
    refute_equal acronym, "FBI"
    refute_equal acronym, "NASA"
    refute_equal acronym, "nba"
  end

  def test_sorted_array
    assert_equal sorted_array, [1, 2, 3]

    refute_equal sorted_array, [3, 2, 1]
  end

  def test_array_of
    assert_equal array_of(any_integer), [1, 2, 3]

    refute_equal array_of(any_integer), [1, "a", 3]
  end

  def test_even_number
    assert_equal even_number, 2
    refute_equal even_number, 1
  end

  def test_odd_number
    assert_equal odd_number, 1
    refute_equal odd_number, 2
  end

  # AnyUnique is probably a terrible idea
  def test_any_unique
    assert_equal any_unique, 1
    assert_equal any_unique, 2
  end

  def test_any_unique_failure
    assert_equal any_unique, 1
    refute_equal any_unique, 1
  end

  def test_any_unique_composition
    unique_string = any_unique ^ any_string
    assert_equal unique_string, "a"
    assert_equal unique_string, "b"
    assert_equal unique_string, "c"
    refute_equal unique_string, "c"
    refute_equal unique_string, 42
  end

  # Increasing is probably a terrible idea as well
  def test_increasing
    assert_equal increasing, 1
    assert_equal increasing, 2
    assert_equal increasing, 3
    refute_equal increasing, 1
    assert_equal increasing, 2
    assert_equal increasing, 3
  end

  def test_any_time
    assert_equal any_time, Time.now
    refute_equal any_time, 42
  end

  def test_any_date
    assert_equal any_date, Date.new
    refute_equal any_date, 42
  end
end

