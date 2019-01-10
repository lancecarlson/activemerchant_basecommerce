module ActiveMerchant
  module Billing
    class BaseCommerceGateway < Gateway
      self.live_url = 'https://gateway.basecommerce.com'
      self.test_url = 'https://gateway.basecommercesandbox.com'

      self.supported_cardtypes  = [:visa, :master, :american_express, :discover, :jcb, :diners_club, :maestro]
      self.supported_countries  = ['US']
      self.homepage_url         = 'http://www.basecommerce.com/'
      self.display_name         = 'Base Commerce'

      def initialize(options = {})
        requires!(options, :login)
        requires!(options, :password)
        requires!(options, :key)
        super
      end

      def authorize(money, payment_method, options={})
      end

      def purchase(money, payment_method, options={})
        params = {

        }
        commit('API_processBankAccountTransactionV4', params)
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

      def parse(body)
        body
      end

      def post_data(params)
        params.collect do |key, value|
          "#{key}=#{value.to_s}"
        end.join('&')
      end

      def commit(action, parameters)
        url = (test? ? self.test_url : self.live_url)
        response = parse(ssl_post(url, post_data(parameters)))
      end
    end
  end
end