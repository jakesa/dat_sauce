# This file is a list of methods intended to provide help output for a user

module DATSauce

  module Help
    class << self
      def help(param)
        case param
          when :run_config
            #print out json config file
          else
            "#{param} is not supported"
        end
      end
    end

  end


end