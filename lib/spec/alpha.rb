
require "~/dat_sauce/lib/dat_sauce"

params = {
    :project_name => 'Apollo',
    :run_options => ["-p prod", "DRIVER=selenium"],
    :test_directory=> './features',
    :outputs => ['CustomHandler'],
    :run_location => {:location => 'local'},
    :number_of_processes => 10
}

DATSauce.run_tests(params)