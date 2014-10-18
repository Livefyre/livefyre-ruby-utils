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

    def init(network, id, key)
      data = SiteData.new(id, key)
      Site.new(network, SiteValidator::validate(data))
    end

    def build_livecomments_collection(title, article_id, url)
      build_collection(CollectionType::LIVECOMMENTS, title, article_id, url)
    end

    def build_liveblog_collection(title, article_id, url)
      build_collection(CollectionType::LIVEBLOG, title, article_id, url)
    end

    def build_livechat_collection(title, article_id, url)
      build_collection(CollectionType::LIVECHAT, title, article_id, url)
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
      Collection.init(self, type, title, article_id, url)
    end

		def urn
			"#{@network.urn}:site=#{@data.id}"
		end
	end
end