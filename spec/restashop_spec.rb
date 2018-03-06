require 'restashop'

RSpec.describe Restashop do
  context 'with fully working setup' do
    it 'fetch resources and provide associated symbols' do
      stub_request(:get, 'http://prestashop.com/api?output_format=JSON')
        .with(headers: {
                'Accept' => '*/*'
              })
        .to_return(status: 200, body: '[ "shops" ]', headers: {})

      restashop = Restashop.new(URI.parse('http://prestashop.com/api').to_s,
                                user: 'XXX')

      expect(restashop.resources).to eq ['shops']
      expect(restashop.shops.class).to eq Shops
    end

    it 'list resource IDs' do
      stub_request(:get, 'http://prestashop.com/api?output_format=JSON')
        .with(headers: {
                'Accept' => '*/*'
              })
        .to_return(status: 200,
                   body: '[ "suppliers" ]', headers: {})

      stub_request(:get, 'http://prestashop.com/api/suppliers?output_format=JSON')
        .with(headers: {
                'Accept' => '*/*'
              })
        .to_return(status: 200,
                   body: '{"suppliers":[{"id":10},{"id":32},{"id":42}]}',
                   headers: {})

      restashop = Restashop.new(URI.parse('http://prestashop.com/api').to_s,
                                user: 'XXX')

      expect(restashop.suppliers.list).to eq [10, 32, 42]
    end

    it 'count resource IDs' do
      stub_request(:get, 'http://prestashop.com/api?output_format=JSON')
        .with(headers: {
                'Accept' => '*/*'
              })
        .to_return(status: 200,
                   body: '[ "suppliers" ]', headers: {})

      stub_request(:get, 'http://prestashop.com/api/suppliers?output_format=JSON')
        .with(headers: {
                'Accept' => '*/*'
              })
        .to_return(status: 200,
                   body: '{"suppliers":[{"id":10},{"id":32},{"id":42}]}',
                   headers: {})

      restashop = Restashop.new(URI.parse('http://prestashop.com/api').to_s,
                                user: 'XXX')

      expect(restashop.suppliers.count).to eq 3
    end

    it 'returns all resource items in a row' do
      stub_request(:get, 'http://prestashop.com/api?output_format=JSON')
        .with(headers: {
                'Accept' => '*/*'
              })
        .to_return(status: 200,
                   body: '[ "suppliers" ]', headers: {})

      stub_request(:get, 'http://prestashop.com/api/suppliers?display=full&output_format=JSON')
        .with(headers: {
                'Accept' => '*/*'
              })
        .to_return(status: 200,
                   body: '{"suppliers":[' \
                   '{"id":3,"name":"Super supplier"},' \
                   '{"id":4,"name":"Mega supplier"}' \
                   ']}',
                   headers: {})

      restashop = Restashop.new(URI.parse('http://prestashop.com/api').to_s,
                                user: 'XXX')

      suppliers = restashop.suppliers.all
      expect(suppliers.class).to eq Array
      expect(suppliers.count).to eq 2
      expect(suppliers[0].class).to eq Supplier
    end

    it 'find a resource using ID' do
      stub_request(:get, 'http://prestashop.com/api?output_format=JSON')
        .with(headers: {
                'Accept' => '*/*'
              })
        .to_return(status: 200, body: '[ "suppliers" ]', headers: {})

      stub_request(:get, 'http://prestashop.com/api/suppliers/42?output_format=JSON')
        .with(headers: {
                'Accept' => '*/*'
              })
        .to_return(status: 200,
                   body: '{"supplier":{"id":42, "name":"Super supplier"}}',
                   headers: {})
      restashop = Restashop.new(URI.parse('http://prestashop.com/api').to_s,
                                user: 'XXX')
      supplier = restashop.suppliers.find(42)
      expect(supplier.class).to eq Supplier
      expect(supplier.name).to eq 'Super supplier'
    end

    it 'show a resource keys' do
      stub_request(:get, 'http://prestashop.com/api?output_format=JSON')
        .with(headers: {
                'Accept' => '*/*'
              })
        .to_return(status: 200, body: '[ "suppliers" ]', headers: {})

      stub_request(:get, 'http://prestashop.com/api/suppliers/42?output_format=JSON')
        .with(headers: {
                'Accept' => '*/*'
              })
        .to_return(status: 200,
                   body: '{"supplier":{"id":42, "name":"Super supplier"}}',
                   headers: {})
      restashop = Restashop.new(URI.parse('http://prestashop.com/api').to_s,
                                user: 'XXX')
      supplier = restashop.suppliers.find(42)
      expect(supplier.keys.count).to eq 2
      expect(supplier.keys).to include 'id'
      expect(supplier.keys).to include 'name'
    end
  end
end
