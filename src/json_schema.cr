require "json"

module JSON
  struct Property
    include JSON::Serializable
    property description : String?
    property type : String
    property items : Hash(String, String)?
    property minimum : Float64?
    # property maximum : Float64?       # TBD
    # property exclusiveMinimum : Bool? # TBD
    # property exclusiveMaximum : Bool? # TBD
    # property minItems : Int64?       # TBD
    # property maxItems : Int64?       # TBD
    # property uniqueItems : Bool?     # TBD
    property properties : Hash(String, Property)?
    property required : Array(String)?

    def validate(key, type, value)
      # puts "#{key} => #{value}  : #{type}"
      case type
      when "integer"
        raise "Invalid integer value #{value} for key #{key}" if value.as_i.nil?
      when "string"
        raise "Invalid string value #{value} for key #{key}" if value.as_s.nil?
      when "number"
        raise "Invalid number value #{value} for key #{key}" unless (n = value.as_f?) && (@minimum.nil? || (minimum = @minimum.as Float64) && n >= minimum)
      when "array"
        raise "Array is missing items or type declaration" unless (items = @items.as Hash(String, String)) && items["type"]?
        array_type = items["type"]
        a = value.as_a
        a.each do |item|
          validate key, array_type, item
        end
      when "object"
        h = value.as_h
        if properties = @properties.as Hash(String, Property)
          raise "Missing required key(s) under key #{key}" if (required = @required.as? Array(String)) && required != (required & properties.keys & h.keys)
          properties.each do |property_key, property|
            property.validate(property_key, property.type, h[property_key]) if h[property_key]?
          end
        end
      else
        raise "Unknown type #{type}"
      end
    end
  end

  struct Schema
    include JSON::Serializable
    property title : String
    property type : String
    property properties : Hash(String, Property)
    property required : Array(String)?

    def validate(any : JSON::Any)
      raise "root type is not 'object'" unless @type == "object"
      h = any.as_h
      raise "Missing required key(s)" if (required = @required.as? Array(String)) && required != (required & @properties.keys & h.keys)
      @properties.each do |property_key, property|
        property.validate property_key, property.type, h[property_key] if h[property_key]?
      end
    end
  end
end
