require 'rest-client'
require 'json'

require 'active_support/inflector/methods'

# PrestaShop API accessor
class Restashop
  include ActiveSupport::Inflector
  # Generic resource
  class Resource
    include ActiveSupport::Inflector
    attr_reader :id

    def initialize(api, resource, id, content = {})
      @api = api
      @resource = resource
      @id = id
      @content = content
    end

    def fetch
      @content = JSON.parse(@api["#{@resource}/#{@id}"]
                     .get(params: { output_format: 'JSON' })
                     .body)[singularize(@resource)]
    end

    def content
      fetch if @content.empty?
      @content
    end

    def keys
      fetch if @content.empty?
      @content.keys
    end

    def method_missing(name)
      fetch if @content.empty?
      @content[name.to_s] || super
    end

    def respond_to_missing?(name, include_private = false)
      super
    end
  end

  # Generic resource collection
  class ResourceCollection
    include ActiveSupport::Inflector
    def initialize(api, resource)
      @api = api
      @resource = resource
    end

    def all
      resources = []
      JSON.parse(@api[@resource].get(params: { output_format: 'JSON',
                                               display: 'full' })
          .body)[@resource].each do |r|
        resources.push constantize(singularize(@resource.capitalize))
          .new(@api, @resource, r['id'], r)
      end
      resources
    end

    def find(id)
      constantize(singularize(@resource.capitalize)).new(@api, @resource, id)
    end

    def list
      ids = []
      JSON.parse(@api[@resource].get(params: { output_format: 'JSON' })
           .body)[@resource]
          .each { |i| ids.push i['id'] }
      ids
    end

    def count
      list.count
    end
  end

  def initialize(url, key)
    @url = url
    @key = key
    @client = RestClient::Resource.new url, user: key, password: ''
    resources.each do |r|
      define_singleton_method r.to_sym do
        create_resource_klass(singularize(r.capitalize))
        create_resource_collection_klass(r.capitalize)
        constantize(r.capitalize).new(@client, r)
      end
    end
  end

  def resources
    r = @client.get(params: { output_format: 'JSON' }).body
    JSON.parse(r)
  end

  def create_klass(klass, superklass)
    if Object.const_defined?(klass)
      Object.const_get(klass)
    else
      Object.const_set(klass, Class.new(superklass))
    end
  end

  def create_resource_klass(klass)
    create_klass klass, Resource
  end

  def create_resource_collection_klass(klass)
    create_klass klass, ResourceCollection
  end
end
