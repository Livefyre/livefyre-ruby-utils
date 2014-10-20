require 'livefyre/exception/livefyre_exception'

module Livefyre
  class CollectionData
    attr_accessor :id, :type, :title, :article_id, :url, :tags, :topics, :extensions

    def initialize(type, title, article_id, url)
      @type = type
      @title = title
      @article_id = article_id
      @url = url
    end

    def as_hash
      hash = {}
      self.instance_variables.each {|var| hash[var.to_s.delete('@')] = self.instance_variable_get(var) }
      hash['articleId'] = @article_id
      hash.delete('article_id')
      hash.delete('id')
      hash
    end

    def id
      if (defined?(@id)).nil?
        raise LivefyreException, 'Call create_or_update on the collection to set the id.'
      end
      @id
    end
  end
end