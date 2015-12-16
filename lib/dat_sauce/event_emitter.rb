# used for emitting events to the database
# will work with or replace the idea of the database_connection class

module DATSauce

  class EventEmitter

    attr_accessor :type

    def initialize(type, db=false)
      #progress bar, TeamCity, MongoDB
      @type = type
      case type
        when 'progress_bar'
          @emitter = DATSauce::ProgressBarEventHandler.new # maybe this should be ProcessBarEventHandler
        when 'team_city'
          @emitter = DATSauce::TCEventHandler.new
        else
          @emitter = nil
          raise "#{type} is not a valid type. Call #types to get a list of valid types"
      end
      @db = DATSauce::DataBase.new if db # class for sending database events to the node.js app
      # TODO: may want to add some connection tests in the Database class for making sure it can reach the server
    end

    # event = {:type, :message}
    def emit_event(event={})
      @emitter.process_event(event)

      if @db && db_event?(event)
        #emit database event
        @db.process_event(event)
      end
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