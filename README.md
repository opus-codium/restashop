# RestaShop

Library to use PrestaShop in Ruby using its API.

## Features

* Read any resources provided by PrestaShop
* Only fetch resources data when needed
* Fetch all in a row when requested
* Provide collection and resources separatly as classes (e.g. `Products` and `Product`)

## Installation

In `Gemfile`:

```ruby
gem 'restashop', git: 'https://github.com/opus-codium/restashop'
```

## Usage

### Connect to PrestaShop

```ruby
require 'restashop'

restashop = Restashop.new('http://prestashop.com/api', 'super secret token')
```

### Fetch available resources

```ruby
restashop.resources
```

### List all IDs of a resource (e.g. products)

```ruby
restashop.products.list
```

### Fetch all entities corresponding to a resource (e.g. supplier)

```ruby
suppliers = restashop.suppliers.all
suppliers.each { |s| puts s.name }
```
Note: it could be really slow on big shop. If you already know resource ID, prefer use `find`.

### Fetch one entity (e.g. order)

```
first_order_id = restashop.orders.list.first
first_order = restashop.orders.find first_order_id
first_order.total_paid
```

## Tests

```
bundle exec rspec
```
