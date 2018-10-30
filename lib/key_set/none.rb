# frozen_string_literal: true

class KeySet
  class None < KeySet
    public_class_method :new

    def self.class_sort_index
      0
    end

    def represents_none?
      true
    end

    def invert
      KeySet.all
    end

    def remove(other)
      case other
      when All
        # we have nothing, we remove everything => we have nothing
        KeySet.none
      when None
        # we have nothing, we remove nothing => we have nothing
        KeySet.none
      when Some
        # we have nothing, we remove some => we have nothing
        KeySet.none
      when AllExceptSome
        # we have nothing, we remove all except some => we have nothing
        KeySet.logger.warn "KeySet removing AllButSome, probably a mistake. this: NONE, removing keys: #{other.keys.inspect}"
        KeySet.none
      else
        raise ArgumentError, 'it needs a valid KeySet'
      end
    end

    def intersect(other)
      case other
      when All
        KeySet.none
      when None
        KeySet.none
      when Some
        KeySet.none
      when AllExceptSome
        KeySet.none
      else
        raise ArgumentError, 'it needs a valid KeySet'
      end
    end
  end
end
