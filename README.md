# KeySet

[![Maintainability](https://api.codeclimate.com/v1/badges/eea7d889d4f13fbf45c7/maintainability)](https://codeclimate.com/github/eturino/ruby_key_set/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/eea7d889d4f13fbf45c7/test_coverage)](https://codeclimate.com/github/eturino/ruby_key_set/test_coverage)
[![Build Status](https://travis-ci.org/eturino/ruby_key_set.svg?branch=master)](https://travis-ci.org/eturino/ruby_key_set)
[![Gem Version](https://badge.fury.io/rb/key_set.svg)](https://badge.fury.io/rb/key_set)

KeySet allows you to represent the 4 possible sets of elements:

- All elements (`KeySet.all # => KeySet::All`)
- No elements (`KeySet.non # => KeySet::None`)
- Some elements (`KeySet.some(['k1', 'k2']) # => KeySet::Some`)
- All except some elements (`KeySet.all_except_some(['k1', 'k2']) # => KeySet::AllExceptSome`)

and do some operations on them, like:
- calculate inverse KeySet (`key_set.invert`)
- remove a KeySet from another KeySet (`key_set.remove(other)`)
- intersect 2 KeySets (`key_set.intersect(other)`)

The keys in the `Some` and `AllExceptSome` key sets are stored in a `SortedSet`, so they are sorted and without duplicates. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'key_set'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install key_set

## Usage

KeySet allows you to represent the 4 possible sets of elements:

- All elements (`KeySet.all # => KeySet::All`)
- No elements (`KeySet.non # => KeySet::None`)
- Some elements (`KeySet.some(['k1', 'k2']) # => KeySet::Some`)
- All except some elements (`KeySet.all_except_some(['k1', 'k2']) # => KeySet::AllExceptSome`)

and do some operations on them, like:
- calculate inverse KeySet (`key_set.invert`)
- remove a KeySet from another KeySet (`key_set.remove(other)`)
- intersect 2 KeySets (`key_set.intersect(other)`)

The keys in the `Some` and `AllExceptSome` key sets are stored in a `SortedSet`, so they are sorted and without duplicates. 

### Creation

```ruby
KeySet.all # => new KeySet of KeySet::All

KeySet.none # => new KeySet of KeySet::None

KeySet.some(['k1', 'k2']) # => new KeySet of KeySet::Some with keys ['k1', 'k2'] 
KeySet.some([]) # => same as KeySet.none => returns new KeySet::None 

KeySet.all_except_some(['k1', 'k2']) # => new KeySet of KeySet::AllExceptSome with keys ['k1', 'k2'] 
KeySet.all_except_some([]) # => same as KeySet.all => returns new KeySet::All 
```

### Checks

```ruby
key_set.represents_all? # => true if the key set is a KeySet::All
key_set.represents_none? # => true if the key set is a KeySet::None
```

### `.invert`

```ruby
KeySet.all.invert # => KeySet::None
KeySet.none.invert # => KeySet::None
KeySet.some(['k1', 'k2']).invert # => KeySet::AllExceptSome with keys 'k1' and 'k2'
KeySet.all_except_some(['k1', 'k2']).invert # => KeySet::Some with keys 'k1' and 'k2'
```

### `.intersect`

```
  #intersect
    All
      KeySet.all.intersect(KeySet.all)
        we have everything, we intersect everything => we have everything
      KeySet.all.intersect(KeySet.none)
        we have everything, we intersect nothing => we have nothing
      KeySet.all.intersect(KeySet.some [key1, key2])
        we have everything, we intersect some => we have some
      KeySet.all.intersect(KeySet.all_except_some [key1, key2])
        we have everything, we intersect all except some => we have all except some
    None
      KeySet.none.intersect(KeySet.all)
        we have nothing, we intersect everything => we have nothing
      KeySet.none.intersect(KeySet.none)
        we have nothing, we intersect nothing => we have nothing
      KeySet.none.intersect(KeySet.some [key1, key2])
        we have nothing, we intersect some => we have nothing
      KeySet.none.intersect(KeySet.all_except_some [key1, key2])
        we have nothing, we intersect all except some => we have nothing
    Some
      KeySet.some([key1, key3]).intersect(KeySet.all)
        we have some, we intersect everything => we have the same some
      KeySet.some([key1, key3]).intersect(KeySet.none)
        we have some, we intersect nothing => we have nothing
      KeySet.some([key1, key3]).intersect(KeySet.some [key1, key2])
        we have some, we intersect some others (that does not include our entire set) => we have the common keys
      KeySet.some([key1, key3]).intersect(KeySet.some [key1, key2, key3])
        we have some, we intersect some others that includes our entire set => we have the common keys, so our former set
      KeySet.some([key1, key3]).intersect(KeySet.all_except_some [key1, key2])
        we have some, we intersect all except others, which includes some of ours => we have the former keys that are not in the other keys
      KeySet.some([key1, key3]).intersect(KeySet.all_except_some [key1, key2, key3])
        we have some, we intersect all except others, which include all our keys => we have nothing
      KeySet.some([key1, key3]).intersect(KeySet.all_except_some [key2, key4])
        we have some, we intersect all except others, none of them are in our keys => we have the same set
    AllExceptSome
      KeySet.all_except_some([key1, key3]).intersect(KeySet.all)
        we have all except some, we intersect everything => we have the same
      KeySet.all_except_some([key1, key3]).intersect(KeySet.none)
        we have all except some, we intersect nothing => we have none
      KeySet.all_except_some([key1, key3]).intersect(KeySet.some [key1, key2])
        we have all except some, we intersect some others => we have the keys in the second that area not in the keys of the first
      KeySet.all_except_some([key1, key3]).intersect(KeySet.some [key1, key3])
        we have all except some, we intersect some of the same keys => we have nothing
      KeySet.all_except_some([key1, key3]).intersect(KeySet.some [key1, key2, key3])
        we have all except some, we intersect some others that includes our entire set => we have the keys in the second that area not in the keys of the first
      KeySet.all_except_some([key1, key3]).intersect(KeySet.all_except_some [key1, key2])
        we have all except some, we intersect all except others (that includes some of the current set) => we get all except the union of keys in the first and in the second
      KeySet.all_except_some([key1, key3]).intersect(KeySet.all_except_some [key1, key2, key3])
        we have all except some, we intersect all except others (that includes the entire of the current set) => we get all except the union of keys in the first and in the second
      KeySet.all_except_some([key1, key3]).intersect(KeySet.all_except_some [key2, key4])
        we have all except some, we intersect all except others (that includes none of the current set) => we get all except the union of keys in the first and in the second
      KeySet.all_except_some([key1, key3]).intersect(KeySet.all_except_some [key1, key3])
        we have all except some, we intersect all except others (that has the same set) => we get the same
```

### `.intersect`

```
#remove
  All
    KeySet.all.remove(KeySet.all)
      we have everything, we remove everything => we have nothing
    KeySet.all.remove(KeySet.none)
      we have everything, we remove nothing => we have everything
    KeySet.all.remove(KeySet.some [key1, key2])
      we have everything, we remove some => we have all except those
    KeySet.all.remove(KeySet.all_except_some [key1, key2])
      we have everything, we remove all except some => we have only those
  None
    KeySet.none.remove(KeySet.all)
      we have nothing, we remove everything => we have nothing
    KeySet.none.remove(KeySet.none)
      we have nothing, we remove nothing => we have nothing
    KeySet.none.remove(KeySet.some [key1, key2])
      we have nothing, we remove some => we have nothing
    KeySet.none.remove(KeySet.all_except_some [key1, key2])
      we have nothing, we remove all except some => we have nothing
  Some
    KeySet.some([key1, key3]).remove(KeySet.all)
      we have some, we remove everything => we have nothing
    KeySet.some([key1, key3]).remove(KeySet.none)
      we have some, we remove nothing => we have the same set
    KeySet.some([key1, key3]).remove(KeySet.some [key1, key2])
      we have some, we remove some others (that does not include our entire set) => we have the keys that we have not been removed
    KeySet.some([key1, key3]).remove(KeySet.some [key1, key2, key3])
      we have some, we remove some others that includes our entire set => we have nothing
    KeySet.some([key1, key3]).remove(KeySet.all_except_some [key1, key2])
      we have some, we remove all except others => we have only the keys that we had and they were excluded from the removal
    KeySet.some([key1, key3]).remove(KeySet.all_except_some [key1, key2, key3])
      we have some, we remove all except others, which include all our keys => we have the same keys
    KeySet.some([key1, key3]).remove(KeySet.all_except_some [key2, key4])
      we have some, we remove all except others, none of them are in our keys => we have nothing
  AllExceptSome
    KeySet.all_except_some([key1, key3]).remove(KeySet.all)
      we have all except some, we remove everything => we have nothing
    KeySet.all_except_some([key1, key3]).remove(KeySet.none)
      we have all except some, we remove nothing => we have the same (all but these keys)
    KeySet.all_except_some([key1, key3]).remove(KeySet.some [key1, key2])
      we have all except some, we remove some others => we have all except the ones that we didn't have before and the ones that we don't have now
    KeySet.all_except_some([key1, key3]).remove(KeySet.some [key1, key2, key3])
      we have all except some, we remove some others that includes our entire set => we have all except the new set (that includes the old set)
    KeySet.all_except_some([key1, key3]).remove(KeySet.all_except_some [key1, key2])
      we have all except some, we remove all except others (that includes some of the current set) => we have only the ones that OTHER did not remove, except the ones that THIS was excluding
    KeySet.all_except_some([key1, key3]).remove(KeySet.all_except_some [key1, key2, key3])
      we have all except some, we remove all except others (that includes the entire of the current set) => we have only the ones that OTHER did not remove, except the ones that THIS was excluding
    KeySet.all_except_some([key1, key3]).remove(KeySet.all_except_some [key2, key4])
      we have all except some, we remove all except others (that includes none of the current set) => we get only the ones that the other is not excluding
    KeySet.all_except_some([key1, key3]).remove(KeySet.all_except_some [key1, key3])
      we have all except some, we remove all except others (that has the same set) => we get nothing
```

Note that removing a AllExceptSome logs a warning, since it is probably not what you want to do.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/eturino/ruby_key_set. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the KeySet project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/eturino/ruby_key_set/blob/master/CODE_OF_CONDUCT.md).
