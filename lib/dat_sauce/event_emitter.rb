# used for emitting events to the database
# will work with or replace the idea of the database_connection class

module DATSauce

  class EventEmitter

    attr_accessor :type
    #TODO add nil as a type here so users can get the standard cucumber output while the tests are running
    def initialize(type)
      #progress bar, TeamCity, MongoDB
      #the event handler will be responsible for sending events to the database
      @type = type
      case type
        when 'progress_bar'
          @emitter = DATSauce::ProgressBarEventHandler.new # maybe this should be ProcessBarEventHandler
        when 'team_city'
          @emitter = DATSauce::TCEventHandler.new
        else
          @emitter = DATSauce::EventHandler.new
      end
    end

    # event = {:type, :message}
    def emit_event(event={})
      @emitter.process_event(event)
    end

    def types
      t = ['progress_bar', 'team_city']
      puts t
      t
    end

    def db_event?(event)
      db_events.include? event
    end

    def event?(event)
      events.include? event
    end

    # a list of all available events
    def events
      ["start_test_run",
       "stop_test_run",
       "start_rerun",
       "test_run_completed",
       "test_created",
       "start_test",
       "stop_test",
       "test_completed",
       "info",
       "debug"]
    end

    # a reference as to which events I believe should write things to the database
    def db_events
      ["start_test_run",
       "stop_test_run",
       "test_run_completed",
       "test_created",
       "start_test",
       "stop_test",
       "test_completed"]
    end

  end


end