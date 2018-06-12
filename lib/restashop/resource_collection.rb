class Restashop
  # Generic resource collection
  class ResourceCollection
    include ActiveSupport::Inflector
    def initialize(restashop, resource)
      @restashop = restashop
      @api = restashop.client
      @resource = resource
    end

    def all
      where({})
    end

    def find(id)
      resource_class.new(@restashop, @resource, id)
    end

    def list
      json = @api[@resource].get(params: { io_format: 'JSON' })
                            .body
      JSON.parse(json)[@resource]
          .map { |i| i['id'] }
    end

    def count
      list.count
    end

    def where(filters)
      params = { io_format: 'JSON', display: 'full' }
      filters.each do |k, v|
        params["filter[#{k}]"] = v
      end
      json = @api[@resource].get(params: params)
                            .body
      JSON.parse(json)[@resource].map do |r|
        resource_class.new(@restashop, @resource, r['id'], r)
      end
    end

    def resource_class
      constantize("Restashop::#{singularize(@resource.capitalize)}")
    end
  end
end
