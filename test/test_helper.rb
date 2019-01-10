$:.unshift File.expand_path('../../lib', __FILE__)

require 'bundler/setup'

require 'test/unit'
require 'mocha/test_unit'
require 'date'
require 'dotenv/load'
require 'uri'

require 'activemerchant_basecommerce'

if ENV['DEBUG_ACTIVE_MERCHANT'] == 'true'
  require 'logger'
  ActiveMerchant::Billing::Gateway.logger = Logger.new(STDOUT)
  ActiveMerchant::Billing::Gateway.wiredump_device = STDOUT
end

module ActiveMerchantBaseCommerce
  module Fixtures
    def default_expiration_date
      @default_expiration_date ||= Date.new((Time.now.year + 1), 9, 30)
    end

    def credit_card(number = '4111111111111111', options = {})
      defaults = {
        :number => number,
        :month => default_expiration_date.month,
        :year => default_expiration_date.year,
        :first_name => 'Longbob',
        :last_name => 'Longsen',
        :name => 'Tester Jones',
        :verification_value => options[:verification_value] || '123',
        :brand => 'visa'
      }.update(options)

      defaults
    end

    def check(options = {})
      defaults = {
        :name => 'Jim Smith',
        :bank_name => 'Bank of Elbonia',
        :routing_number => '244183602',
        :account_number => '15378535',
        :account_holder_type => 'personal',
        :account_type => 'checking',
        :number => '1'
      }.update(options)

      defaults
    end

    def address(options = {})
      {
        name:     'Jim Smith',
        street:   '456 My Street',
        street2:  'Apt 1',
        company:  'Widgets Inc',
        city:     'Ottawa',
        state:    'ON',
        zip:      'K1C2N6',
        country:  'CA',
        phone:    '(555)555-5555',
        fax:      '(555)555-6666'
      }.update(options)
    end

    def credentials
      login = ENV.fetch('BASECOMMERCE_USERNAME')
      password = ENV.fetch('BASECOMMERCE_PASSWORD')
      key = ENV.fetch('BASECOMMERCE_KEY')
      {login: login, password: password, key: key}
    end

    def payment_create(payment_method, gateway_id=:usa_epay, options={})
      gateway = credentials(gateway_id)
      gateway.merge!({id: gateway_id.to_s})
      create = {
        request_token: SecureRandom.uuid,
        transaction: {
          amount_in_cents: 100,
          email: 'testerjones@healpay.com',
          phone: '123-123-1234',
          description: 'HealPay Transaction',
          invoice: '123',
          order_id: SecureRandom.uuid,
          line_items: [
            {description: 'line item 1', total_in_cents: 40},
            {description: 'line item 2', total_in_cents: 60}
          ],
          sec_code: 'WEB',
          custom_fields: {
            '1': '123did',
            '2': '123cid',
            '3': 'I-2',
            '4': 'AF-10001',
            '5': '0acc2155-718d-4403-a571-8b1111c7cfef',
            '6': 'true',
            '7': 'AF-10001',
            '8': 'some custom thing'
          },
          client_ip: '123.123.123.123'
        },
        gateway: gateway,
        settlementapp: {
          payment_type: 'partial',
        }
      }

      if payment_method.is_a?(Cashier::PaymentMethod::Token)
        create[:transaction][:payment_method_type] = payment_method.type
        create[:transaction][:payment_method_token] = payment_method.to_am
      else
        crypto = GPGME::Crypto.new :armor => true
        encrypted_payment_method = crypto.encrypt(payment_method.to_json, :recipients => ENV.fetch('PGP_RECIPIENTS')).to_s
        create[:transaction][:payment_method_payload] = encrypted_payment_method

        create[:transaction][:payment_method_type] = payment_method.has_key?(:routing_number) ? 'check' : 'card'
      end

      create[:transaction][:billing] = options[:billing] if options[:billing]

      create
    end
  end
end

Test::Unit::TestCase.class_eval do
  include ActiveMerchant::Billing
  include ActiveMerchantBaseCommerce::Fixtures
end
