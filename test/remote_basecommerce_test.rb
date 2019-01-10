require 'test_helper'

class RemoteBaseCommerceTest < Test::Unit::TestCase
  def setup
    @gateway = BaseCommerceGateway.new(credentials)
    @credit_card = credit_card
    @declined_card = credit_card('4000300011112220')
    @check = check({account_number: '123123123123', routing_number: '021000021'})
    @options = { :billing_address => address(:zip => '27614', :state => 'NC'), :shipping_address => address }
    @amount = 100
  end

  def test_successful_card_purchase
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    #pp response
    assert_equal 'Success', response.message
    assert_success response
  end

  def test_successful_check_purchase
    @options[:bank_account_method] = 'WEB'
    assert response = @gateway.purchase(@amount, @check, @options)
    #pp response
    assert_equal 'Success', response.message
    assert_success response
  end
end