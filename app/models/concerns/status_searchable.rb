#require 'elasticsearch/model'

module StatusSearchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    index_name  "pawoo"
    document_type "status"

    #  settings index: { ... }
    #mappings dynamic: 'false' do ... end

    def as_indexed_json(options = {})
      if public_visibility?
        {
          id: id,
          text: text,
        }
      else
        {}
      end
    end

    after_commit on: [:create] do
      Rails.logger.debug 'is toot public?'
      Rails.logger.debug public_visibility?
      if public_visibility?
        Rails.logger.debug 'toot is sent to ES.@create'
        __elasticsearch__.index_document
      else
        Rails.logger.debug 'toot is not sent to ES.@create'
      end
    end

    after_commit on: [:destroy] do
      __elasticsearch__.delete_document
    end
  end

  class_methods do
    def search(query)
      __elasticsearch__.search({
        "query": {
          "simple_query_string": {
            "query": query,
            "fields": ["text"],
            "default_operator": "and"
          }
        },
        "sort": [{
          "@timestamp": {
            "order": "desc",
            "missing": "_last"
          }
        }]
      })
    end
  end

end
