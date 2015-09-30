require_relative 'custom_accessor'
module DATSauce
  class BaseTest
    extend CustomAccessor

    def to_hash
      obj = {}
      Test.attrs.each do |attr|
        obj[attr] = send(attr)
      end
      obj
    end

    def to_json
      JSON.generate to_hash
    end
  end
end
