require 'rest-client'
require 'pry'

module DATResults
  class ScreenShotApi

    attr_accessor :url

    def initialize(url)
      @url = url
    end

    def get

    end

    def list

    end

    def upload(path, file_name)
      begin
        RestClient.post url, :screen_shot => File.new(path + file_name, 'rb')
      rescue RestClient::ExceptionWithResponse => e
        e.response
      end
    end

    def delete

    end
  end
end
