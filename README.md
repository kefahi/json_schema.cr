# json_schema

An attempt to implement [json schema](https://json-schema.org/) validation in Crystal.

Work in progress but could be a useful start

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     json_schema:
       github: kefahi/json_schema.cr
   ```

2. Run `shards install`

## Usage

`data.json`
```json
{
    "id": 1,
    "name": "A green door",
    "price": 12.50,
    "tags": ["home", "green"]
}
```

`schema.json`
```json
{
    "$schema": "http://json-schema.org/draft-04/schema#",
    "title": "Product",
    "description": "A product from Acme's catalog",
    "type": "object",
    "properties": {
      "id": {
          "description": "The unique identifier for a product",
          "type": "integer"
      },
      "name": {
          "description": "The unique identifier for a product",
          "type": "string"
      },
      "price": {
          "type": "number",
          "minimum": 0,
          "exclusiveMinimum": true
      },
      "dimensions": {
          "type": "object",
          "properties": {
              "length": {"type": "number"},
              "width": {"type": "number"},
              "height": {"type": "number"}
          },
          "required": ["length", "width", "height"]
      }
			
    },
    "required": ["id"]
}
```

`Sample code`
```crystal
require "json_schema"
json_data = JSON.parse File.read "data.json" 
schema = JSON::Schema.from_json File.read "schema.json"
schema.validate json_data
```

## Contributing

1. Fork it (<https://github.com/kefahi/json_schema.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Kefah Issa](https://github.com/kefahi) - This is a continuation on work from [DougEverly](https://github.com/DougEverly/json_schema.cr)
