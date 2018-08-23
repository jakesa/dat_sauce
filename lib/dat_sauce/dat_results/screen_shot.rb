require 'json'
require_relative 'screen_shot_api'

module DATResults

  class ScreenShot

    def initialize(url=nil)
      raise ArgumentError.new('Screen Shot URL was not provided') if url.nil?
      @api = ScreenShotApi.new(url)
    end

    def record_screen_shot(path, file_name)
      res = @api.upload(path, file_name)
      if res.code == 201
        [true, nil]
      else
        [false, JSON.parse(res.body, :symbolize_names=>true)]
      end
    end
  end
end
