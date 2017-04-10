
module DATSauce

  class EventHandler

    #--
    # TODO - I want to add the ability to pass in a different io to the handler similar to what cucumber does with its --out switch
    #++


      def self.event_handlers
        {
            :progress_bar => ProgressBarEventHandler,
            :team_city => TCEventHandler,
            :default => DefaultEventHandler,
            :database => DBEventHandler
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

      # event fired when a test run is started
      # @param test_run DATSauce::TestRun
      def start_test_run(test_run)
        #stub meant to be overridden
        raise NoMethodError
      end

      # event fired when a test run is stopped
      # @param test_run DATSauce::TestRun
      def stop_test_run(test_run)
        #stub meant to be overridden
        raise NoMethodError
      end

      # event fired when a rerun is started
      # @param test_run DATSauce::TestRun
      def start_rerun(test_run)
        #stub meant to be overridden
        raise NoMethodError
      end

      # event fired when a test run is completed
      # @param test_run DATSauce::TestRun
      def test_run_completed(test_run)
        #stub meant to be overridden
        raise NoMethodError
      end

      # event fired when a test object is created
      # @param test DATSauce::Test
      def test_created(test)
        #stub meant to be overridden
        raise NoMethodError
      end

      # event fired when a test is started
      # @param test DATSauce::Test
      def start_test(test)
        #stub meant to be overridden
        raise NoMethodError
      end

      # event fired when a test is stopped
      # @param test DATSauce::Test
      def stop_test(test)
        #stub meant to be overridden
        raise NoMethodError
      end

      # event fired when a test is completed
      # @param test DATSauce::Test
      def test_completed(test)
        #stub meant to be overridden
        raise NoMethodError
      end

      # event fired when and info event is fired
      # this is usually status information. Things like telling the user all threads are full and sending remaining tests to a queu
      # @param message String
      def info(message)
        #stub meant to be overridden
        raise NoMethodError
      end
    end
end



