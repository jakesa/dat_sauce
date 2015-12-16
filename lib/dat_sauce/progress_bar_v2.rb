require 'curses'

module DATSauce

  class ProgressBar

    attr_accessor :current_count, :count, :current_progress, :pass_count, :fail_count, :run_type, :current_failures

    #params for initializing progress bar
    def initialize(params={})
      @current_index_max = 0
      @pass_count = 0
      @fail_count = 0
      @current_failures = []
      @run_type = 'primary'
      Curses.noecho

      @count = params[:count].nil? ? 0 : params[:count]
    end

    def start_progress
      Curses.init_screen
      @current_count = 0
      @current_progress = ""
      display_progress_window
    end

    def increment(by)
      @current_count += by
    end

    #output a message above the progress bar
    def output(message)
      @status_message = message
      Curses.refresh
    end

    def start_timer
      @timer_count = '00:00:00'
      @timer ||= Thread.new {
        count = 0
        loop do
          @timer_count = Time.at(count).utc.strftime("%H:%M:%S")
          display_progress_window
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
    end

    private

    def output_to_curses(index_1, index_2, message)
      Curses.setpos(index_1, index_2)
      Curses.addstr(message)
      Curses.refresh
    end

    def display_progress_window
      Curses.clear
      current_index = 0
      Curses.setpos(current_index, 0)
      Curses.addstr("Current Run Type: #{@run_type}")
      Curses.setpos(current_index +=1, 0)
      Curses.addstr("Passed: #{@pass_count}")
      Curses.setpos(current_index +=1, 0)
      Curses.addstr("Failed: #{@fail_count}")
      Curses.setpos(current_index +=1, 0)
      Curses.addstr("Status Message: #{@status_message}")
      Curses.setpos(current_index +=1, 0)
      Curses.addstr("Progress: #{@current_count}/#{@count} (#{@timer_count}) <=== %#{((@current_count.to_f / @count.to_f)*100).to_i} ===>")
      Curses.setpos(current_index +=1, 0)
      Curses.addstr("Current Failures:")
      Curses.setpos(current_index +=1, 0)
      Curses.addstr(process_failures)
      Curses.refresh
    end

    def process_failures
      failures = ''
      @current_failures.flatten.each do |failure|
        failures << "#{failure}\n"
      end
      failures
    end

    def to_s
      "Current Run Type: #{@run_type}\nPassed: #{@pass_count}\nFailed: #{@fail_count}\nProgress: #{@current_count}/#{@count} (#{@timer_count})<#{((@current_count.to_f / @count.to_f)*100).to_i}>\nCurrent Failures:\n #{process_failures}"
    end

  end

  class ProgressBarEventHandler < DATSauce::EventHandler


    private

    def start_test_run(test_run)
      @progress_bar = DATSauce::ProgressBar.new({:count => test_run.test_count})
      @progress_bar.start_progress
      @progress_bar.start_timer
    end

    def test_run_completed(test_run)
      @progress_bar.finish
      #TODO: may do something with the test object here.
    end

    def test_completed(test)
      @progress_bar.increment 1

      if test.results[:rerun].nil?
        if test.results[:primary].status == 'Passed'
          @progress_bar.pass_count += 1
        else
          @progress_bar.fail_count += 1
          @progress_bar.current_failures << test.results[:primary].failed_tests
        end
      else
        if test.results[:rerun].status == 'Passed'
          @progress_bar.pass_count += 1
        else
          @progress_bar.fail_count += 1
          @progress_bar.current_failures << test.results[:rerun].failed_tests
        end
      end

    end

    def start_rerun(count)
      @progress_bar.count = count
      @progress_bar.run_type = 'rerun'
      @progress_bar.pass_count = 0
      @progress_bar.fail_count = 0
      @progress_bar.current_count = 0
      @progress_bar.current_failures = []
    end

    def info(message)
      @progress_bar.output message
    end


  end

end