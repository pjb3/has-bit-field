module HasBitField

  def self.silently_fail=(val)
    @silently_fail = val
  end

  def self.silently_fail?
    @silently_fail || false
  end

  # The first arguement +bit_field_attribute+ should be a symbol,
  # the name of attribute that will hold the actual bit field
  # all following arguments should also be symbols,
  # which will be the name of each flag in the bit field
  def has_bit_field(bit_field_attribute, *args)
    unless table_exists?
      msg = "[has_bit_field] table undefined #{table_name}"
      raise ArgumentError.new(msg) unless HasBitField.silently_fail?
      Rails.logger.error("[has_bit_field] table undefined #{table_name}") if defined?(Rails) && Rails.respond_to?(:logger)
      return
    end

    if columns_hash[bit_field_attribute.to_s].blank?
      msg = "[has_bit_field] column undefined #{bit_field_attribute} (in #{table_name})"
      raise ArgumentError.new(msg) unless HasBitField.silently_fail?
      Rails.logger.error(msg) if defined?(Rails) && Rails.respond_to?(:logger)
      return
    end

    args.each_with_index do |field,i|
      class_eval %{
        class << self
          def #{field}_bit
            (1 << #{i})
          end
        end

        def #{field}
          (#{bit_field_attribute} & self.class.#{field}_bit) != 0
        end

        alias #{field}? #{field}

        def #{field}=(v)
          if v.to_s == "true" || v.to_s == "1"
            self.#{bit_field_attribute} = (#{bit_field_attribute} || 0) | self.class.#{field}_bit
          else
            self.#{bit_field_attribute} = (#{bit_field_attribute} || 0) & ~self.class.#{field}_bit
          end
        end

        def #{field}_was
          (#{bit_field_attribute}_was & self.class.#{field}_bit) != 0
        end

        def #{field}_changed?
          #{field} != #{field}_was
        end
      }

      if columns_hash[bit_field_attribute.to_s].null
        scope field, lambda {
          where(arel_table[bit_field_attribute].not_eq(nil).
                and(Arel::Nodes::InfixOperation.new(:&, arel_table[bit_field_attribute], 1<<i).not_eq(0)))
        }
        scope "not_#{field}", lambda {
          where(arel_table[bit_field_attribute].eq(nil).
                or(Arel::Nodes::InfixOperation.new(:&, arel_table[bit_field_attribute], 1<<i).eq(0)))
        }
      else
        scope field, lambda {
          where(Arel::Nodes::InfixOperation.new(:&, arel_table[bit_field_attribute], 1<<i).not_eq(0))
        }
        scope "not_#{field}", lambda {
          where(Arel::Nodes::InfixOperation.new(:&, arel_table[bit_field_attribute], 1<<i).eq(0))
        }
      end

    end
  end
end
