module Sauce
  class << self
    attr_writer :desired_capabilities

    def username
      # TODO: add a check for this and have user add it
      ENV['SAUCE_USERNAME']
    end

    def access_key
      # TODO: add a check for this and have user add it
      ENV['SAUCE_ACCESS_KEY']
    end

    def authentication
      "#{username}:#{access_key}"
    end

    def sauce_server
      'ondemand.saucelabs.com'
    end

    def sauce_port
      80
    end

    def endpoint
      "http://#{authentication}@#{sauce_server}:#{sauce_port}/wd/hub"
    end

    def environment_capabilities
      browser = ENV['SAUCE_BROWSER']
      version = ENV['SAUCE_VERSION']
      platform = ENV['SAUCE_PLATFORM']

      if browser && version && platform
        return {
            :browserName => browser,
            :version => version,
            :platform => platform
        }
      end

      return nil
    end

    #TODO: add more logic for specifying caps
    def default_capabilities
      {
          :browserName => "Chrome",
          :version => nil,
          :platform => "Linux"
      }
    end

    def desired_caps
      environment_capabilities || @desired_capabilities || default_capabilities
    end

    def webdriver_config
      {
          :browser => :remote,
          :url => endpoint,
          :desired_capabilities => desired_caps
      }
    end
  end
end