# frozen_string_literal: true

module Sinatra
  module Helpers
    module InternalTimeoutHelper
      def remaining_time(start_time)
        55 - (Time.now.to_i - start_time)
      end

      def execute_with_timeout(start_time)
        if remaining_time(start_time) > 45
          yield
        else
          raise InternalTimeoutError
        end
      end
    end
  end
end
