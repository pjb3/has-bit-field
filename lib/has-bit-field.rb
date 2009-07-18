module HasBitField
  # The first arguement +bit_field_attribute+ should be a symbol,
  # the name of attribute that will hold the actual bit field
  # all following arguments should also be symbols,
  # which will be the name of each flag in the bit field
  def has_bit_field(bit_field_attribute, *args)
    args.each_with_index do |field,i|
      flag = (1 << i)
      define_method("#{field}?") do
        (send(bit_field_attribute) & flag) != 0
      end
      define_method("#{field}=") do |v|
        if v.to_s == "true" || v.to_s == "1"
          send("#{bit_field_attribute}=", ((send(bit_field_attribute) || 0) | flag))
        else
          send("#{bit_field_attribute}=", ((send(bit_field_attribute) || 0) & ~flag))
        end
      end
    end
  end
end