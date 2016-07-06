require_relative 'event_handler'
require_relative 'progress_bar/progress_bar'
require_relative 'team_city/team_city'
require_relative '../constantize'
module EventHandlerRegister
  include DATSauce::Constantize
  # Get an array of handlers to register
  # If a handler that is passed in is not valid, it will not be matched with a handler and ignored
  # @param [Array<String>] handlers list of handlers you want to use for this test run
  # @return [Array<Objects>] The list of matched handlers
  def get_event_handlers(handlers)
    # convert the input into an array
    if handlers.nil?
      puts "WARNING: There were no handlers passed to the EventHandlerRegister#get_event_handlers. Please make sure your params are correct"
      handlers = []
    else
      handlers = [handlers] unless handlers.is_a? Array
    end
    require_custom_handlers if custom_handler?(handlers)
    _handlers = load_handlers handlers
    check_stdout _handlers
    _handlers
  end

  private
  # check to see if there are any conflicting handlers
  # @param [Array<EventHandler>] handlers an array of handlers to check
  def check_stdout(handlers)
    count = 0
    handlers.each do |handler|
      count += 1 if handler.stdout?
    end

    raise 'There were multiple event handlers that require the use of STDOUT. Please use only one event handler that requires STDOUT' if count > 1
  end

  # checks the array of handlers for a custom handler. It will return true on the first one it finds. Will return false if none are detected
  # @param [Array<String>] handlers an array of handlers
  # @return [Boolean]
  def custom_handler?(handlers)
    handlers.each do |handler|
      if !DATSauce::EventHandler.event_handlers.include?(handler.to_sym)
        return true
      end
    end
    false
  end

  # loads the custom handler files
  # @return [void]
  def require_custom_handlers
    if Dir.exist? './features/support/handlers'
      Dir.glob("*.rb").each {|file| require "#{file}"}
    else
      raise "A custom handler was passed but the './features/support/handlers' directory does not exist. Please create the directory and place your custom handler file in it"
    end
  end

  # load handlers
  # @param [Array<Object>] handlers an array of handler references
  # @return [Array<EventHandler>] an array of event handler objects
  def load_handlers(handlers)
    _handlers = []
    handlers.each do |handler|
      begin
        _handlers << DATSauce::EventHandler.event_handlers[handler.to_sym].new
      rescue => e
        # puts e.message
        begin
          const = constantize handler
          _handlers << const.new
        rescue =>e
          # puts e.message
          raise "Unable to load event handler: #{handler}"
        end
      end
    end
    _handlers
  end

end