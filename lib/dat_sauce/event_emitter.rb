# used for emitting events to the database
# will work with or replace the idea of the database_connection class

module DATSauce

  module EventEmitter

    class << self

      TYPES = ['DATABASE', 'TEAMCITY']

      def emit_event(params={})

        case params[:type].upcase
          when 'DATABASE'
            #implement database write here
          when 'TEAMCITY'
            emit_team_city_event(params)
          else
            raise "#{type} is not a valid type. Valid type are: #{TYPES.to_s}"
        end

      end

      def emit_team_city_event(params={})
        # :event, params ={}
        case params[:event]
          when 'start_test'
            DATSauce::TCMessageBuilder.start_test params[:name]
          when 'finish_test'
            DATSauce::TCMessageBuilder.finish_test params[:name]
          when 'start_test_suite'
            DATSauce::TCMessageBuilder.start_test_suite params[:name]
          when 'finish_test_suite'
            DATSauce::TCMessageBuilder.finish_test_suite params[:name]
          when 'test_failed'
            DATSauce::TCMessageBuilder.test_failed params
          when 'report_run_statistics'
            DATSauce::TCMessageBuilder.report_run_statistics params
          when 'report_message'
            DATSauce::TCMessageBuilder.report_message params
          else
            # TODO - add a list output to this error message
            raise "#{params[:event]} is not a valid TeamCity event"
        end
      end


    end


  end


end