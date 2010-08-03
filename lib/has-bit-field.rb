module HasBitField
  # The first arguement +bit_field_attribute+ should be a symbol,
  # the name of attribute that will hold the actual bit field
  # all following arguments should also be symbols,
  # which will be the name of each flag in the bit field
  def has_bit_field(bit_field_attribute, *args)
    args.each_with_index do |field,i|
      (class << self; self end).send(:define_method, "#{field}_bit") do
        (1 << i)
      end
      define_method(field) do
        (send(bit_field_attribute).to_i & self.class.send("#{field}_bit")) != 0
      end
      define_method("#{field}?") do
        send(field)
      end
      define_method("#{field}=") do |v|
        if v.to_s == "true" || v.to_s == "1"
          send("#{bit_field_attribute}=", ((send(bit_field_attribute) || 0) | self.class.send("#{field}_bit")))
        else
          send("#{bit_field_attribute}=", ((send(bit_field_attribute) || 0) & ~self.class.send("#{field}_bit")))
        end
      end
      define_method("#{field}_was") do
        (send("#{bit_field_attribute}_was") & self.class.send("#{field}_bit")) != 0
      end
      define_method("#{field}_changed?") do
        send(field) != send("#{field}_was")
      end
      if(respond_to?(:named_scope))
        named_scope field, :conditions => ["#{table_name}.#{bit_field_attribute} IS NOT NULL AND (#{table_name}.#{bit_field_attribute} & ?) != 0", send("#{field}_bit")]
        named_scope "not_#{field}", :conditions => ["#{table_name}.#{bit_field_attribute} IS NULL OR (#{table_name}.#{bit_field_attribute} & ?) = 0", send("#{field}_bit")]
      end
    end
  end
end
