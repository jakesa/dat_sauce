
module DATSauce

  class EventHandler

    #--
    # TODO - I want to add the ability to pass in a different io to the handler similar to what cucumber does with its --out switch
    #++


      def self.event_handlers
        {
            :progress_bar => ProgressBarEventHandler,
            :team_city => TCEventHandler,
            :default => DATSauce::EventHandler
        }
      end

      # Check to see if the event handler sends its output to stdout.
      # @return [Boolean]
      # @note if it is not set, it will return false
      def stdout?
        @stdout ||= false
      end

      # set the value of @stdout
      # @param [Boolean] value
      def stdout=(value)
        @stdout = value
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
    #--
    # TODO - It might be worth while to implement a full basic default event handler and have all other event handlers inherit from this
    # and override the methods
    end
end



