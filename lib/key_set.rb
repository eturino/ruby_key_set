# frozen_string_literal: true

require 'active_support/all'
class KeySet
  class Error < StandardError
  end

  def self.logger
    @logger ||= default_logger
  end

  def self.default_logger
    require 'logger'
    ::Logger.new($stdout)
  end

  def self.all
    All.new
  end

  def self.none
    None.new
  end

  def self.some(keys)
    return none if keys.blank?

    Some.new keys
  end

  def self.all_except_some(keys)
    return all if keys.blank?

    AllExceptSome.new keys
  end

  private_class_method :new

  # COMMON

  def represents_all?
    false
  end

  def represents_none?
    false
  end

  # @!method remove(other)
  #   removes other key set from the current key set, returning a new one
  #   @param other [KeySet]
  #   @return [KeySet]

  # @!method intersect(other)
  #   intersects with the other key set, returning a new one
  #   @param other [KeySet]
  #   @return [KeySet]

  # @!method invert(other)
  #   returns a new KeySet that represents the inverse of what this one represents
  #   @return [KeySet]

  # EQUALITY AND COMPARISON
  def hash
    if respond_to? :keys
      [self.class.to_s, keys.map(&:hash)].hash
    else
      self.class.to_s.hash
    end
  end

  def <=>(other)
    if self.class.class_sort_index == other.class.class_sort_index
      if respond_to? :keys_array
        keys_array <=> other.keys_array
      else
        0
      end
    else
      self.class.class_sort_index <=> other.class.class_sort_index
    end
  end

  def ===(other)
    self.class == other.class && try(:keys_array) === other.try(:keys_array) # rubocop:disable Style/CaseEquality
  end

  def ==(other)
    self.class == other.class && try(:keys_array) == other.try(:keys_array)
  end

  def eql?(other)
    self.class == other.class && try(:keys_array) == other.try(:keys_array)
  end
end

require 'key_set/based_on_keys'

require 'key_set/all'
require 'key_set/none'
require 'key_set/some'
require 'key_set/all_except_some'

require 'key_set/version'
