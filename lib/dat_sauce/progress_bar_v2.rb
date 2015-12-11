require 'curses'


module DATSauce

  class ProgressBar

    attr_accessor :current_count, :count, :current_progress

    #params for initializing progress bar
    def initialize(params)
      @bar_index = 1
      @text_index = 0
      Curses.noecho

      @count = params[:count].nil? ? 0 : params[:count]
    end

    def start_progress
      # Curses.setpos(@bar_index, 0)
      # Curses.addstr(progress_bar_open)
      # Curses.refresh
      @current_count = 0
      @current_progress = ""
      output_to_curses @bar_index, 0, progress_bar_open
      Curses.init_screen
    end

    def increment(by)
      @current_count += by
      #need to improve this
      progress = "=" * by
      @current_progress << progress unless progress.empty?
      if @current_count >= @count
        finish
      end
    end

    #output a message above the progress bar
    def output(message)
      output_to_curses @text_index, 0, message
    end

    def start_timer
      @timer_count = '00:00:00'
      @timer ||= Thread.new {
        count = 0
        loop do
          @timer_count = Time.at(count).utc.strftime("%H:%M:%S")
          output_to_curses @bar_index, 0, progress_bar_open
          sleep(1)
          count += 1
        end
      }
    end

    def stop_timer
      Thread.kill(@timer)
    end

    def finish
      @current_progress = "Finished"
      @current_count = @count
      stop_timer
      Curses.close_screen
      puts progress_bar_open
    end

    def progress_bar_open
      "Progress: #{@current_count}/#{@count} (#{@timer_count})<#{@current_progress}>"
    end

    private

    def output_to_curses(index_1, index_2, message)
      Curses.setpos(index_1, index_2)
      Curses.addstr(message)
      Curses.refresh
    end

  end

end