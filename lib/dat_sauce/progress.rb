

module DATSauce

  class Progress


    def initialize(test_count, type = 'progress')
      @test_count = test_count
      case type
        when 'progress'
          @bar = ProgressBar.create(:title => "Progress", :starting_at => 0, :total => test_count, :format => '%t: %c/%C : %a <%B>' )
        when 'results'
          @bar = ProgressBar.create(:title => "Processing results", :starting_at => 0, :total => test_count, :format => '%t: %c/%C : %a <%B>' )
        else
          raise "Type: #{type} - Not recognized. Valid types: 'progress', 'results'"
      end
        @bar = ProgressBar.create(:title => "Progress", :starting_at => 0, :total => test_count, :format => '%t: %c/%C : %a <%B>' )
      # @color = $stdout.tty?
      @color = false
      @status = 'pass'

    end

    def title=(title)
      @bar.title = title
      @bar.refresh
    end

    def format(string)
      @bar.format(string)
    end

    def refresh
      if @color
        colorize(@status) {@bar.refresh}
      else
        @bar.refresh
      end
    end

    def reset_status
      @status = 'passed'
    end

    def adjust_total(by)
      @bar.reset
      if @color
        colorize(@status) {@bar.total = (@test_count + by)}
      else
        @bar.total = (@test_count + by)
      end
      @bar.progress = @test_count
    end

    def increment(num, status)
      if @color
        colorize(status) {@bar.increment}
      else
        @bar.increment
      end
      # refresh
      @status = status
    end

    def log(message)
      if @bar.finished?

        if @color
          colorize(@status) {puts message}
        else
          puts message
        end
      else
        if @color
          colorize(@status) {@bar.log message}
        else
          @bar.log message
        end
      end
    end

    def finished?
      @bar.finished?
    end

    def finish
      if @color
        colorize(@status) {@bar.finish}
      else
        @bar.finish
      end

    end

    private

    def colorize(status, &block)
      if @status == 'failed'
        $stdout.print "\e[31m"
        yield
        $stdout.print "\e[0m"
      else
        case status.downcase
          when 'passed'
            $stdout.print "\e[32m"
            yield
            $stdout.print "\e[0m"
          when 'failed'
            $stdout.print "\e[31m"
            yield
            $stdout.print "\e[0m"
          when 'warning'
            $stdout.print "\e[33m"
            yield
            $stdout.print "\e[0m"
          else
            yield
        end
      end
    end

  end
end