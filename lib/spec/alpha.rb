
require "~/dat_sauce/lib/dat_sauce"

params = {
    :project_name => 'Apollo',
    :run_options => ["-p qa", "DRIVER=selenium"],
    :test_directory=> './features/login_and_session/login.feature',
    :rerun => 'parallel',
    :run_location => {:location => 'local'},
    :number_of_processes => 10
}

DATSauce.run_tests(params)