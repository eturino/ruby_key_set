# frozen_string_literal: true

class KeySet
  class Some < KeySet
    public_class_method :new

    include BasedOnKeys

    def self.class_sort_index
      1
    end

    def invert
      KeySet.all_except_some(keys_array)
    end

    def remove(other)
      case other
      when All
        # we have some, we remove everything => we have nothing
        KeySet.none
      when None
        # we have some, we remove nothing => we have the same set
        KeySet.some keys.deep_dup
      when Some
        # we have some, we remove some others => we have some with another set (or maybe none)
        remove_some(other)
      when AllExceptSome
        # we have some, we remove all except others => we remove all except the intersection
        KeySet.logger.warn "KeySet removing AllButSome, probably a mistake. this: SOME, removing keys: #{other.keys.inspect}"
        remove_all_except_some(other)
      else
        raise ArgumentError, 'it needs a valid KeySet'
      end
    end

    def intersect(other)
      case other
      when All
        KeySet.some keys.deep_dup
      when None
        KeySet.none
      when Some
        intersect_with_some(other)
      when AllExceptSome
        intersect_with_all_except_some(other)
      else
        raise ArgumentError, 'it needs a valid KeySet'
      end
    end

    private

    def remove_some(other)
      k = keys.deep_dup - other.keys.deep_dup
      KeySet.some k
    end

    def remove_all_except_some(other)
      k = keys.deep_dup & other.keys.deep_dup
      KeySet.some k
    end

    def intersect_with_all_except_some(other)
      k = keys.deep_dup - other.keys.deep_dup
      KeySet.some k
    end

    def intersect_with_some(other)
      k = keys.deep_dup & other.keys.deep_dup
      KeySet.some k
    end
  end
end
