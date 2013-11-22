module HasBitField
  # The first arguement +bit_field_attribute+ should be a symbol,
  # the name of attribute that will hold the actual bit field
  # all following arguments should also be symbols,
  # which will be the name of each flag in the bit field
  def has_bit_field(bit_field_attribute, *args)
    unless table_exists?
      Rails.logger.error("[has_bit_field] table undefined #{table_name}") if defined?(Rails) && Rails.respond_to?(:logger)
      return
    end
    if columns_hash[bit_field_attribute.to_s].blank?
      Rails.logger.error("[has_bit_field] column undefined #{bit_field_attribute}") if defined?(Rails) && Rails.respond_to?(:logger)
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

      scope_sym = respond_to?(:validates) ? :scope : :named_scope

      if columns_hash[bit_field_attribute.to_s].null
        class_eval %{
          send scope_sym, :#{field}, :conditions => ["#{table_name}.#{bit_field_attribute} IS NOT NULL AND (#{table_name}.#{bit_field_attribute} & ?) != 0", #{field}_bit]
          send scope_sym, :not_#{field}, :conditions => ["#{table_name}.#{bit_field_attribute} IS NULL OR (#{table_name}.#{bit_field_attribute} & ?) = 0", #{field}_bit]          
        }
      else
        class_eval %{
          send scope_sym, :#{field}, :conditions => ["(#{table_name}.#{bit_field_attribute} & ?) != 0", #{field}_bit]
          send scope_sym, :not_#{field}, :conditions => ["(#{table_name}.#{bit_field_attribute} & ?) = 0", #{field}_bit]
        }
      end

    end
  end
end
