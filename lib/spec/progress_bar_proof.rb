#
# test_count = nil
# completed_count =nil
# running_count = nil
# passed_count = nil
# failed_count = nil
# timer = nil
# status = "Tests: #{test_count}
#  Completed: #{completed_count}
#  Currently Running: #{running_count}
#  Passed: #{passed_count}
#  Failed: #{failed_count}"
# progress = "Progress: #{timer} < "
# 1000.times do |i|
#
# # i is number from 0-999
#   j = i + 1
#
#   # add 1 percent every 10 times
#   if j % 10 == 0
#     progress << "="
#     # move the cursor to the beginning of the line with \r
#     print "\r"
#     # puts add \n to the end of string, use print instead
#     print status
#     print progress + " #{j / 10} %"
#
#     # force the output to appear immediately when using print
#     # by default when \n is printed to the standard output, the buffer is flushed.
#     $stdout.flush
#     sleep 0.05
#   end
# end
# puts "\nDone!"

require_relative '../../lib/dat_sauce/progress_bar_v2'

progress_bar = DATSauce::ProgressBar.new({:count =>10})
progress_bar.start_progress
progress_bar.start_timer
progress_bar.output "Running test: This is a Test"
progress_bar.increment 1
sleep 5
progress_bar.increment 8
progress_bar.output "Running test: This is another test"
sleep 5
progress_bar.increment 15


