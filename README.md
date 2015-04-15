# Anything

[![Build Status](https://travis-ci.org/wojtekmach/anything.svg)](https://travis-ci.org/wojtekmach/anything)

Anything is a collection of helper methods like: `anything`, `any_number`, `any_string` that is useful for testing nested data structures (like arrays or hashes) when you care more about some particular elements and the "shape" of the data, than about the entire data structure.

So, instead of either:

* Asserting all elements, even the attributes you don't really care about (ids, created_at fields etc)

```ruby
def test_create
  item1 = Item.create!(name: "Item 1")
  item2 = Item.create!(name: "Item 2")

  get "/items"

  assert_equal [
    {"id" => item1.id, "name" => "Item 1"},
    {"id" => item2.id, "name" => "Item 2"},
  ], JSON(response.body)
end
```

or

* Extracting out subset of attributes you care about:

```ruby
def test_create
  item1 = Item.create!(name: "Item 1")
  item2 = Item.create!(name: "Item 2")

  get "/items"

  assert_equal [
    "Item 1", "Item 2",
  ], JSON(response.body).map { |h| h['name'] }
end
```

You can do this:

```ruby
def test_create
  item1 = Item.create!(name: "Item 1")
  item2 = Item.create!(name: "Item 2")

  get "/items"

  assert_equal [
    {"id" => any_integer, "name" => "Item 1"},
    {"id" => any_integer, "name" => "Item 2"},
  ], JSON(response.body)
end
```

## Usage

All you have to do is to include `Anything` module to your program/test/whatever.

Example:

```ruby
require 'anything'

class Minitest::Test
  include Anything
end

require 'minitest/autorun'

class Test < Minitest::Test
  def test_anything
    assert_equal any_number, 42
  end
end
```

### Composition

You can compose helpers like this:

```ruby
acronym = upcase_string ^ string_of_length(3)

acronym == "NBA"  # => true
acronym == "nba"  # => false
acronym == "NASA" # => false
```

And like that for arrays:

```ruby
array_of_integers = array_of(any_integer)

array_of_integers == [1, 2, 3]   # => true
array_of_integers == [1, nil, 3] # => false
```

See: https://github.com/wojtekmach/anything/blob/master/test/anything_test.rb for more examples.

## Installation

The gem is not released to rubygems.org yet, since this name is taken.

You can install it via bundler by adding `gem 'anything', github: 'wojtekmach/anything'` to your Gemfile or by cloning it and running `rake install`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/anything/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
