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
        raise "Invalid integer value for #{value}" if value.as_i.nil?
      when "string"
        raise "Invalid string value for #{value}" if value.as_s.nil?
      when "number"
        raise "Invalid number value for #{value}" unless (n = value.as_f?) && (@minimum.nil? || (minimum = @minimum.as Float64) && n >= minimum)
      when "array"
        raise "Array is missing items or type declaration" unless (items = @items.as Hash(String, String)) && items["type"]?
        array_type = items["type"]
        a = value.as_a
        a.each do |item|
          validate key, array_type, item
        end
      when "object"
        h = value.as_h
        required = @required.as? Array(String)
        if properties = @properties.as Hash(String, Property)
          properties.each do |property_key, property|
            if h[property_key]?
              property.validate(property_key, property.type, h[property_key])
            elsif required && required.includes? property_key
              raise "Required key is missing #{property_key}"
            end
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
    property required : Array(String)

    def validate(any : JSON::Any)
      raise "root type is not 'object'" unless @type == "object"
      h = any.as_h
      @properties.each do |key, property|
        if h[key]?
          property.validate key, property.type, h[key]
        elsif @required.includes? key
          raise "Required key #{key} is missing"
        end
      end
    end
  end
end
