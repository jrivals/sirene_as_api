module INSEE
  module Operation
    class FetchUpdates < Trailblazer::Operation
      step :init_api_results
      step :fetch_with_cursor
      pass :log_entitites_fetched
      fail :log_operation_failure

      CURSOR_START_VALUE = '*'.freeze

      def init_api_results(ctx, **)
        ctx[:api_results] = []
      end

      # rubocop:disable Metrics/MethodLength
      def fetch_with_cursor(ctx, **)
        next_cursor = CURSOR_START_VALUE
        operation = nil

        loop do
          operation = fetch_operation(ctx, next_cursor)
          break if operation.failure?

          body = operation[:body]

          api_results = body[operation[:api_results_key]]
          ctx[:api_results] += api_results

          next_cursor = body[:header][:curseurSuivant]

          log_progress(ctx, body)
          break if end_reached?(body[:header])
        end

        operation.success?
      end
      # rubocop:enable Metrics/MethodLength

      def log_entitites_fetched(_, model:, api_results:, logger:, **)
        logger.info "Total: #{api_results.size} #{model} fetched"
      end

      def log_operation_failure(_, model:, logger:, **)
        logger.error "Fetching new #{model} failed"
      end

      private

      def fetch_operation(context, next_cursor)
        INSEE::Request::FetchUpdatesWithCursor.call(
          model: context[:model],
          from: context[:from],
          to: context[:to],
          cursor: next_cursor,
          logger: context[:logger]
        )
      end

      def end_reached?(header)
        header[:curseur] == header[:curseurSuivant]
      end

      def log_progress(context, latest_body)
        total = latest_body[:header][:total]
        current_count = context[:api_results].size
        percent = (current_count.to_f / total * 100).round(2)
        context[:logger].info "#{current_count} / #{total} (#{percent}%)"
      end
    end
  end
end
