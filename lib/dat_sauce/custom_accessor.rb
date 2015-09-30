
module CustomAccessor


  def custom_attr_accessor(*attrs)
    @attrs ||= []
    attrs.each { |attr| @attrs << attr}
    attr_accessor *attrs
  end

  def attrs
    @attrs
  end

end