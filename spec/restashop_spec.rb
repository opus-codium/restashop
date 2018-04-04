require 'restashop'

def stub_prestashop(path, json)
  stub_request(:get, "http://prestashop.com/#{path}")
    .with(headers: {
            'Accept' => '*/*'
          })
    .to_return(status: 200, body: json, headers: {})
end

def stub_prestashop_resources
  json = File.read(File.expand_path('api.json', __dir__))
  stub_prestashop 'api?output_format=JSON', json
end

def stub_prestashop_suppliers
  json = '{"suppliers":[{"id":2},{"id":4},{"id":42}]}'
  stub_prestashop 'api/suppliers?output_format=JSON', json
end

def stub_prestashop_suppliers_full
  json = '{"suppliers":[' \
         '{"id":2,"name":"Mega supplier"},' \
         '{"id":4,"name":"Awesome supplier"},' \
         '{"id":42,"name":"Super supplier"}' \
         ']}'
  stub_prestashop 'api/suppliers?output_format=JSON&display=full', json
end

def stub_prestashop_supplier_42
  json = '{"supplier":{"id":42, "name":"Super supplier"}}'
  stub_prestashop 'api/suppliers/42?output_format=JSON', json
end

def stub_prestashop_products
  json = File.read(File.expand_path('products.json', __dir__))
  stub_prestashop 'api/products?output_format=JSON&display=full', json
end

def stub_prestashop_products_with_filter_on_supplier_4
  json = File.read(File.expand_path('products_supplier_4.json', __dir__))
  stub_prestashop 'api/products?output_format=JSON&display=full&filter[id_supplier]=4', json
end

RSpec.describe Restashop do
  let(:restashop) do
    Restashop.new(URI.parse('http://prestashop.com/api').to_s,
                  user: 'XXX')
  end

  before do
    stub_prestashop_resources
  end

  context 'with fully working setup' do

    before do
      stub_prestashop_suppliers
      stub_prestashop_suppliers_full
      stub_prestashop_supplier_42
    end

    it 'fetch resources and provide associated symbols' do
      expect(restashop.resources).to include 'shops'
      expect(restashop.shops.class).to eq Shops
    end

    it 'lists resource IDs' do
      expect(restashop.suppliers.list).to eq [2, 4, 42]
    end

    it 'counts resource IDs' do
      expect(restashop.suppliers.count).to eq 3
    end

    it 'returns all resource items in a row' do
      suppliers = restashop.suppliers.all
      expect(suppliers.class).to eq Array
      expect(suppliers.count).to eq 3
      expect(suppliers[0].class).to eq Supplier
    end

    it 'find a resource using ID' do
      supplier = restashop.suppliers.find(42)
      expect(supplier.class).to eq Supplier
      expect(supplier.name).to eq 'Super supplier'
    end

    it 'show a resource keys' do
      supplier = restashop.suppliers.find(42)
      expect(supplier.keys).to include 'id'
      expect(supplier.keys).to include 'name'
    end
  end

  context 'with representative products catalog' do
    before do
      stub_prestashop_products_with_filter_on_supplier_4
    end

    it 'filters results on `where` call' do
      products = restashop.products.where(id_supplier: 4)
      expect(products.count).to eq 175
    end
  end
end
