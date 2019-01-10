$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'activemerchant_basecommerce'
  s.version     = '0.0.1'
  s.date        = '2019-01-09'
  s.summary     = 'Base Commerce payment gateway integration with ActiveMerchant'
  s.description = 'Active Merchant adapter for the Base Commerce payment gateway'
  s.authors     = ['Lance Carlson']
  s.email       = 'support@healpay.com'
  s.files       = ['lib/activemerchant_basecommerce.rb']
  s.license     = 'MIT'

  s.files = Dir['lib/**/*']
  s.require_path = 'lib'

  s.add_dependency('activemerchant', '>= 1.90')

  s.add_development_dependency('test-unit', '>=3')
  s.add_development_dependency('rake')
end
