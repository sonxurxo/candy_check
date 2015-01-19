module CandyCheck
  module AppStore
    # Verifies an receipt block against a verification server.
    # The call return either an [Receipt] or a [VerificationFailure]
    class Verifier
      # @return [String] the verification URL to use
      attr_reader :endpoint_url
      # @return [String] the raw data to be verified
      attr_reader :receipt_data
      # @return [String] the optional shared secret
      attr_reader :secret

      # Constant for successful responses
      STATUS_OK = 0

      # Builds a fresh verification run
      # @param endpoint_url [String] the verification URL to use
      # @param receipt_data [String] the raw data to be verified
      # @param secret [String] the optional shared secret
      def initialize(endpoint_url, receipt_data, secret = nil)
        @endpoint_url, @receipt_data = endpoint_url, receipt_data
        @secret = secret
      end

      # Performs the verification against the remote server
      # @return [Receipt] or [VerificationFailure]
      def call!
        verify!
        if valid?
          Receipt.new(@response['receipt'])
        else
          VerificationFailure.fetch(@response['status'])
        end
      end

      private

      def valid?
        @response && @response['status'] == STATUS_OK && @response['receipt']
      end

      def verify!
        client    = Client.new(endpoint_url)
        @response = client.verify(receipt_data, secret)
      end
    end
  end
end
