require 'livefyre/core/collection'
require 'livefyre/model/site_data'
require 'livefyre/type/collection_type'
require 'livefyre/validator/site_validator'

module Livefyre
	class Site
    attr_accessor :network, :data
    
		def initialize(network, data)
			@network = network
      @data = data
    end

    def self.init(network, id, key)
      data = SiteData.new(id, key)
      Site.new(network, SiteValidator::validate(data))
    end

    def build_comments_collection(title, article_id, url)
      build_collection(CollectionType::COMMENTS, title, article_id, url)
    end

    def build_blog_collection(title, article_id, url)
      build_collection(CollectionType::BLOG, title, article_id, url)
    end

    def build_chat_collection(title, article_id, url)
      build_collection(CollectionType::CHAT, title, article_id, url)
    end

    def build_counting_collection(title, article_id, url)
      build_collection(CollectionType::COUNTING, title, article_id, url)
    end

    def build_ratings_collection(title, article_id, url)
      build_collection(CollectionType::RATINGS, title, article_id, url)
    end

    def build_reviews_collection(title, article_id, url)
      build_collection(CollectionType::REVIEWS, title, article_id, url)
    end

    def build_sidenotes_collection(title, article_id, url)
      build_collection(CollectionType::SIDENOTES, title, article_id, url)
    end

    def build_collection(type, title, article_id, url)
      Collection::init(self, type, title, article_id, url)
    end

		def urn
			"#{@network.urn}:site=#{@data.id}"
		end
	end
end