
module DATSauce

  class Config


    attr_accessor :database_address, :database_port


    def initialize
      @server_address = 'localhost'
      @server_port = 4723
    end

    def method_missing(name, *args, &block)
      value = args[0]
      if name.match(/^.*=/) != nil
        unless respond_to?(name) || respond_to?("#{name.to_s.gsub('=','')}".to_sym)
          define_singleton_method(name) {|val|instance_variable_set("@#{name.to_s.gsub('=','')}", val)}
          define_singleton_method("#{name.to_s.gsub('=','')}") {instance_variable_get("@#{name.to_s.gsub('=','')}")}
          self.send(name, value)
        end
      else
        nil
      end
    end
  end

end