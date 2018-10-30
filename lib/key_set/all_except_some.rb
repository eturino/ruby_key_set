# frozen_string_literal: true

class KeySet
  class AllExceptSome < KeySet
    public_class_method :new
    include BasedOnKeys

    def self.class_sort_index
      2
    end

    def invert
      KeySet.some(keys_array)
    end

    def remove(other)
      case other
      when All
        # we have all except some, we remove everything => we have nothing
        KeySet.none
      when None
        # we have all except some, we remove nothing => we have the same (all but these keys)
        KeySet.all_except_some keys.deep_dup
      when Some
        # we have all except some, we remove some others => we have all except the ones that we didn't have before and the ones that we don't have now
        remove_some(other)
      when AllExceptSome
        # we have all except some, we remove all except others => we have only the ones that OTHER did not remove, except the ones that THIS was removing
        KeySet.logger.warn "KeySet removing AllButSome, probably a mistake. this: ALL_BUT_SOME, removing keys: #{other.keys.inspect}"
        remove_all_except_some(other)
      else
        raise ArgumentError, 'it needs a valid KeySet'
      end
    end

    def intersect(other)
      case other
      when All
        KeySet.all_except_some keys.deep_dup
      when None
        KeySet.none
      when Some
        # we have all except some, we remove some others => we have all except the ones that we didn't have before and the ones that we don't have now
        intersect_some(other)
      when AllExceptSome
        intersect_all_except_some(other)
      else
        raise ArgumentError, 'it needs a valid KeySet'
      end
    end

    private

    def remove_some(other)
      k = keys.deep_dup + other.keys.deep_dup
      KeySet.all_except_some k
    end

    def remove_all_except_some(other)
      k = other.keys.deep_dup - keys.deep_dup
      KeySet.some k
    end

    def intersect_some(other)
      k = other.keys.deep_dup - keys.deep_dup
      KeySet.some k
    end

    def intersect_all_except_some(other)
      k = other.keys.deep_dup + keys.deep_dup
      KeySet.all_except_some k
    end
  end
end
