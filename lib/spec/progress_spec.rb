require_relative 'spec_helper'
require 'ruby-progressbar'

pb = ProgressBar.create(:title => "Progress", :starting_at => 0, :total => 5, :format => '%t: %c/%C : %a <%B>' )

5.times do
  pb.increment
  sleep 1
end

pb.reset
pb.total = 10
pb.refresh
pb.progress = 5

5.times do
  pb.increment
  sleep 1
end
