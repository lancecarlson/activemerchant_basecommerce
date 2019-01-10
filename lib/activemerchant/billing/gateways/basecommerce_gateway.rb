module ActiveMerchant
  module Billing
    class BaseCommerceGateway < Gateway
      self.live_url = 'https://gateway.basecommerce.com'
      self.test_url = 'https://gateway.basecommercesandbox.com'

      self.supported_cardtypes  = [:visa, :master, :american_express, :discover, :jcb, :diners_club, :maestro]
      self.supported_countries  = ['US']
      self.homepage_url         = 'http://www.basecommerce.com/'
      self.display_name         = 'Base Commerce'

      CHECK_METHODS = %w(CCD PPD TEL WEB POP BOC ARC RCK)

      def initialize(options = {})
        requires!(options, :login)
        requires!(options, :password)
        requires!(options, :key)
        super
      end

      def authorize(money, payment_method, options={})
      end

      def purchase(money, payment_method, options={})
        params = build_request(money, payment_method, options)
        commit("API_process#{payment_method_action(payment_method)}TransactionV4", params)
      end

      def capture(money, authorization, options={})
      end

      def void(identification, options={})
      end

      def refund(money, identification, options = {})
      end

      def verify(payment_method, options={})
      end

      private

      # Standard Active Merchant utility methods start here

      def post_data(params)
        {
          gateway_username: options[:login],
          gateway_password: options[:password],
          payload: encrypt(params.to_json)
        }.to_json
      end

      def parse(body)
        JSON.parse(decrypt(body))
      end

      def commit(action, parameters)
        url = (test? ? self.test_url : self.live_url)
        url = "#{url}/pcms/?f=#{action}"
        response = parse(ssl_post(url, post_data(parameters)))

        success = success_from(response)
        Response.new(success, message_from(success, response), response)
      end

      def success_from(response)
        !response.has_key?(:exception)
      end

      def message_from(success, response)
        response.fetch('bank_account_transaction').fetch('bank_account_transaction_status').fetch('bank_account_transaction_status_description')
      end

      # Base Commerce specific utility methods start here

      def encrypt(body)
        cipher = OpenSSL::Cipher.new "des-ede3"
        cipher.encrypt
        cipher.padding = 1
        cipher.key = [options[:key]].pack('H*')
        cipher_result = ""
        cipher_result << cipher.update(body)
        cipher_result << cipher.final
        return cipher_result.unpack('H*')[0]
      end

      def decrypt(body)
        cipher = OpenSSL::Cipher.new "des-ede3"
        cipher.decrypt
        cipher.padding = 1
        cipher.key = [options[:key]].pack('H*')
        cipher_result = ""
        cipher_result << cipher.update([body].pack('H*'))
        cipher_result << cipher.final
        return cipher_result
      end

      def payment_method_action(payment_method)
        if payment_method.is_a?(CreditCard)
          'BankCard'
        elsif payment_method.is_a?(Check)
          'BankAccount'
        else
          raise TypeError, 'Payment method not supported'
        end
      end

      def build_request(money, payment_method, options)
        params = {amount: money}
        build_payment_method(params, payment_method, options)
      end

      def build_payment_method(params, payment_method, options)
        #if payment_method.is_a?(String)
        #  doc.payment_method_token(payment_method)
        if payment_method.is_a?(CreditCard)
          build_credit_card(params, payment_method, options)
        elsif payment_method.is_a?(Check)
          build_check(params, payment_method, options)
        else
          raise TypeError, 'Payment method not supported'
        end
      end

      def build_credit_card(params, payment_method, options)
      end

      def build_check(params, payment_method, options)
        raise ArgumentError, 'missing bank_account_method option' if options[:bank_account_method].nil?
        raise ArgumentError, "bank_account_method option must be one of: #{CHECK_METHODS.join(', ')}" unless CHECK_METHODS.include?(options[:bank_account_method])

        params.merge({
          bank_account_transaction_account_name: payment_method.name,
          bank_account_transaction_account_number: payment_method.account_number,
          bank_account_transaction_routing_number: payment_method.routing_number,
          #bank_account_transaction_type: 'debit'.upcase,
          bank_account_transaction_account_type: payment_method.account_type.upcase,
          bank_account_transaction_amount: params[:amount],
          bank_account_transaction_method: options[:bank_account_method]
        })
      end
    end
  end
end