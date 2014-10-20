require 'simplecov'
require 'coveralls'

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter 'spec/'
  add_filter 'lib/livefyre/exception'
end

Coveralls.wear!

NETWORK_NAME = ENV['NETWORK_NAME'] || '<NETWORK-NAME>'
NETWORK_KEY = ENV['NETWORK_KEY'] || '<NETWORK-KEY>'
SITE_ID = ENV['SITE_ID'] || '<SITE-ID>'
SITE_KEY = ENV['SITE_KEY'] || '<SITE-KEY>'
COLLECTION_ID = ENV['COLLECTION_ID'] || '<COLLECTION-ID>'
USER_ID = ENV['USER_ID'] || '<USER-ID>'
ARTICLE_ID = ENV['ARTICLE_ID'] || '<ARTICLE-ID>'
URL = 'http://answers.livefyre.com/RUBY'