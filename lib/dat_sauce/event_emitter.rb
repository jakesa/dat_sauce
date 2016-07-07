
module DATSauce

  # Emits events to the registered event emitters
  class EventEmitter

    attr_accessor :event_handlers
    #TODO add nil as a type here so users can get the standard cucumber output while the tests are running
    def initialize
      #progress bar, TeamCity, MongoDB
      #the event handler will be responsible for sending events to the database
      @event_handlers = []
    end

    def register_event_handlers(handlers)
      @event_handlers << handlers
      @event_handlers.flatten!
    end

    # event = {:type, :message}
    def emit_event(event={})
        @event_handlers.each do |handler|
          handler.process_event(event)
        end unless @event_handlers.empty?
        # --
        # Below is a prototype for processing events in parallel
        # Will revisit this after some metric runs with the base iteration model
        # threads = []
        # @event_handlers.each do |handler|
        #   threads << Thread.new(handler, event) { |h, e|
        #     h.procecss_event(e)
        #   }
        # end
        # threads.each do |t|
        #   t.join
        # end
        # ++
    end

    # output a list of registered event handlers
    def list_event_handlers
      puts @event_handlers
    end

    # check to see if the specified event is one that can be written to a database
    # @return [Boolean]
    def db_event?(event)
      db_events.include? event
    end

    # checks to see if the specified event is an event emitted by the emitter
    # @return [Boolean]
    def event?(event)
      events.include? event
    end

    # a list of all available events
    # @return [Array<String>]
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
    # @return [Array<String>]
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