require 'simplecov'
require 'coveralls'

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter 'spec/'
  add_filter 'lib/livefyre/exceptions'
end

Coveralls.wear!

begin
  config = File.open('test.yml') { |yf| YAML::load(yf) }
  env = config['production']

  NETWORK_NAME = env['NETWORK_NAME']
  NETWORK_KEY = env['NETWORK_KEY']
  SITE_ID = env['SITE_ID']
  SITE_KEY = env['SITE_KEY']
  COLLECTION_ID = env['COLLECTION_ID']
  USER_ID = env['USER_ID']
  ARTICLE_ID = env['ARTICLE_ID']
rescue
  NETWORK_NAME = ENV['NETWORK_NAME'] || '<NETWORK-NAME>'
  NETWORK_KEY = ENV['NETWORK_KEY'] || '<NETWORK-KEY>'
  SITE_ID = ENV['SITE_ID'] || '<SITE-ID>'
  SITE_KEY = ENV['SITE_KEY'] || '<SITE-KEY>'
  COLLECTION_ID = ENV['COLLECTION_ID'] || '<COLLECTION-ID>'
  USER_ID = ENV['USER_ID'] || '<USER-ID>'
  ARTICLE_ID = ENV['ARTICLE_ID'] || '<ARTICLE-ID>'
end

URL = 'http://answers.livefyre.com/RUBY'