
module DATSauce

  class EventHandler

    def initialize

    end

    def process_event(event={})
      event.each do |key,value|
        begin
          send(key.to_sym, value)
        rescue NoMethodError
          nil #catch an event that has not been implemented
        end
      end


    end

  end

end



