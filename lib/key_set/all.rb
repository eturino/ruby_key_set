# frozen_string_literal: true

class KeySet
  class All < KeySet
    public_class_method :new

    def self.class_sort_index
      3
    end

    def represents_all?
      true
    end

    def invert
      KeySet.none
    end

    def remove(other)
      case other
      when All
        # we have everything, we remove everything => we have nothing
        KeySet.none
      when None
        # we have everything, we remove nothing => we have everything
        KeySet.all
      when Some
        # we have everything, we remove some => we have all except those
        KeySet.all_except_some other.keys
      when AllExceptSome
        # we have everything, we remove all except some => we have only those
        KeySet.logger.warn "KeySet removing AllButSome, probably a mistake. this: ALL, removing keys: #{other.keys.inspect}"
        KeySet.some other.keys
      else
        raise ArgumentError, 'it needs a valid KeySet'
      end
    end

    def intersect(other)
      case other
      when All
        KeySet.all
      when None
        KeySet.none
      when Some
        KeySet.some other.keys
      when AllExceptSome
        KeySet.all_except_some other.keys
      else
        raise ArgumentError, 'it needs a valid KeySet'
      end
    end
  end
end
