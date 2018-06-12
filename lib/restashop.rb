require 'rest-client'
require 'json'

require 'active_support/inflector/methods'

require 'restashop/resource'
require 'restashop/resource_collection'

# PrestaShop API accessor
class Restashop
  include ActiveSupport::Inflector
  attr_reader :client
  def initialize(url, key)
    @url = url
    @key = key
    @client = RestClient::Resource.new url, user: key, password: ''
    resources.each do |r|
      define_singleton_method r.to_sym do
        create_resource_class(singularize(r.capitalize))
        create_resource_collection_class(r.capitalize)
        constantize("Restashop::#{r.capitalize}").new(self, r)
      end
    end
  end

  def resources
    json = @client.get(params: { io_format: 'JSON' }).body
    JSON.parse(json)
  end

  def find_or_create_class(klass, superklass)
    if Restashop.const_defined?(klass)
      Restashop.const_get(klass)
    else
      Restashop.const_set(klass, Class.new(superklass))
    end
  end

  def create_resource_class(klass)
    find_or_create_class klass, Resource
  end

  def create_resource_collection_class(klass)
    find_or_create_class klass, ResourceCollection
  end
end
