require 'rest-client'
require 'json'

require 'active_support/inflector/methods'

# PrestaShop API accessor
class Restashop
  include ActiveSupport::Inflector
  attr_reader :client
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
             .get(params: { output_format: 'JSON' })
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

  # Generic resource collection
  class ResourceCollection
    include ActiveSupport::Inflector
    def initialize(restashop, resource)
      @restashop = restashop
      @api = restashop.client
      @resource = resource
    end

    def all
      json = @api[@resource].get(params: { output_format: 'JSON',
                                           display: 'full' })
                            .body
      JSON.parse(json)[@resource].map do |r|
        resource_class.new(@restashop, @resource, r['id'], r)
      end
    end

    def find(id)
      resource_class.new(@restashop, @resource, id)
    end

    def list
      ids = []
      json = @api[@resource].get(params: { output_format: 'JSON' })
                            .body
      JSON.parse(json)[@resource]
          .each { |i| ids.push i['id'] }
      ids
    end

    def count
      list.count
    end

    def resource_class
      constantize(singularize(@resource.capitalize))
    end
  end

  def initialize(url, key)
    @url = url
    @key = key
    @client = RestClient::Resource.new url, user: key, password: ''
    resources.each do |r|
      define_singleton_method r.to_sym do
        create_resource_class(singularize(r.capitalize))
        create_resource_collection_class(r.capitalize)
        constantize(r.capitalize).new(self, r)
      end
    end
  end

  def resources
    json = @client.get(params: { output_format: 'JSON' }).body
    JSON.parse(json)
  end

  def find_or_create_class(klass, superklass)
    if Object.const_defined?(klass)
      Object.const_get(klass)
    else
      Object.const_set(klass, Class.new(superklass))
    end
  end

  def create_resource_class(klass)
    find_or_create_class klass, Resource
  end

  def create_resource_collection_class(klass)
    find_or_create_class klass, ResourceCollection
  end
end
