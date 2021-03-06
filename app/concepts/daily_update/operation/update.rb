class DailyUpdate
  module Operation
    class Update < Trailblazer::Operation
      pass :log_update_period
      step Nested INSEE::Operation::FetchUpdates
      step Nested Task::AdaptApiResults
      pass :log_supersede_starts
      step :supersede

      def supersede(_, model:, results:, logger:, **)
        results.each do |item|
          DailyUpdate::Task::Supersede.call(
            model: model,
            data: item,
            logger: logger
          )
        end
      end

      def log_update_period(_, from:, to:, logger:, **)
        logger.info "Importing from #{from} to #{to}"
      end

      def log_supersede_starts(_, results:, logger:, **)
        logger.info "Supersede starts ; #{results.size} update to perform"
      end
    end
  end
end
