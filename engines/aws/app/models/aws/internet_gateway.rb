module AWS
  class InternetGateway < AWSResource

    def attach_to_vpc(vpc_id)
      @cli.attach_internet_gateway(vpc_id, self.id)
      self.refresh()
    end

    def create_command
      response = @cli.create_internet_gateway
      self.id = JSON.parse(response)['InternetGateway']['InternetGatewayId']
      self.refresh()
    end

    def destroy_command
      self.refresh()
      @framework_attributes['InternetGateways'].first['Attachments'].each do |attachment|
        @cli.detach_internet_gateway(attachment['VpcId'], self.id)
      end
      @cli.delete_internet_gateway(self.id)
      throw(:abort) unless Rails.configuration.lasso_run.present?

      self.wait_until(:not_found)
    end

    def describe_resource
      @cli.describe_internet_gateway(self.id)
    end

    def state_attribute
      if @framework_attributes['State']
        @framework_attributes['State']
      elsif @framework_attributes['InternetGateways']&.first
        'available'
      end
    end
  end
end
