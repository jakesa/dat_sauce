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

    def to_s(log = false)
      str = ''
      Test.attrs.each do |attr|
        str << "#{attr}: #{send(attr)}\n" unless attr == :log && !log
      end
    end
  end

end
