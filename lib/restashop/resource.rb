class Restashop
  # Generic resource
  class Resource
    include ActiveSupport::Inflector
    attr_reader :id

    def initialize(restashop, resource, id, content = nil)
      @restashop = restashop
      @api = restashop.client
      @resource = resource
      @id = id
      @content = content
    end

    def fetch
      json = @api["#{@resource}/#{@id}"]
             .get(params: { io_format: 'JSON' })
             .body
      @content = JSON.parse(json)[singularize(@resource)]
    end

    def content
      @content ||= fetch
    end

    def keys
      content.keys
    end

    def method_missing(name)
      content[name.to_s] || super
    end

    def respond_to_missing?(name, include_private = false)
      super
    end
  end
end
