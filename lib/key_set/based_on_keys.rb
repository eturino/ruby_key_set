# frozen_string_literal: true

class KeySet
  module BasedOnKeys
    extend ActiveSupport::Concern

    included do
      include Enumerable

      attr_reader :keys

      def initialize(keys)
        @keys = SortedSet.new(keys.to_a)
      end

      delegate :each, to: :keys
    end

    def keys_array
      keys.to_a
    end

    def represents_all?
      false
    end

    def represents_none?
      false
    end

    def clone
      self.class.new keys.deep_dup
    end
  end
end
