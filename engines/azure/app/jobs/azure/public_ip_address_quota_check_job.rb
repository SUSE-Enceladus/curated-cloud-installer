return unless defined?(PreFlight::Engine)

module Azure
  class PublicIpAddressQuotaCheckJob < ApplicationJob
    queue_as :default

    def perform(check_id:)
      check = PreFlight::Check.find(check_id)
      quota = Azure::PublicIpAddressQuota.new()
      check.passed = quota.sufficient_capacity?
      check.view_data = {
        region: Azure::Region.load().value
      }
      check.job_completed_at = DateTime.now
      check.save
    end
  end
end
