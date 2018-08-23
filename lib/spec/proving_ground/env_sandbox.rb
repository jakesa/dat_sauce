require 'pry'
require 'dotenv'
ENV['TEST_RUN_ID'] = 'test1'

sub_process = Object::IO.popen('ruby ./env_sandbox_sub_proc.rb')

Process.wait2(sub_process.pid)

binding.pry