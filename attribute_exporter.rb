# gem install httparty

require 'httparty'
require 'uri'
require 'csv'

APPBOY_URL = 'https://api.appboy.com/users/track'
FILE_NAME = 'user_ids_to_export.csv'
VALID_ATTRIBUTE_PREFIX = 'looker_export.'

class AttributeExporter
  def initialize
    full_array = CSV.read(FILE_NAME, "r:ISO-8859-1")

    @array_count = full_array.length
    @array_of_ids = full_array.each_slice(50).to_a

    header_row = @array_of_ids[0].shift
    @attribute_name = header_row[1]
    @user_id_column_name = header_row[0]
  end

  def send_if_confirmed
    if is_valid_user_id_name
      if is_valid_attribute_name
        if is_confirmed
          batch_send_attributes
        else
          puts "Attribute export cancelled."
        end
      else
        puts "Second CSV column (attribute name) must start with 'looker_export.' Attribute name given: #{@attribute_name}"
      end
    else
      puts "First CSV column (user ID) must be named 'user_id'"
    end
  end

  private

  def is_valid_user_id_name
    @user_id_column_name == 'user_id'
  end

  def is_valid_attribute_name
    @attribute_name.start_with?(VALID_ATTRIBUTE_PREFIX)
  end

  def is_confirmed
    puts "Import #{@array_count} records to attribute name '#{@attribute_name}'? (y/n)"
    return gets.chomp.downcase == 'y'
  end

  def batch_send_attributes
    count = 0
    @array_of_ids.each do |array_batch|
      array_of_attributes = []
      array_batch.each do |user_item|
        count += 1
        array_of_attributes << user_attributes_object(user_item)
      end
      attribute_payload = payload(array_of_attributes)
      response = call_appboy(attribute_payload)
      if response.code == 201
        puts("#{count + 1} out of #{@array_count} users processed")
      else
        puts("Error:")
        puts(response)
      end
    end
  end

  def call_appboy(attribute_payload)
    HTTParty.post(APPBOY_URL, body: attribute_payload.to_json, headers: headers)
  end

  def payload(array_of_attributes)
    {
      "app_group_id" => ENV['APPBOY_APP_GROUP_ID_PRODUCTION'],
      "attributes" => array_of_attributes
    }
  end

  def user_attributes_object(user_item)
    user_id = user_item[0]
    attribute_value = user_item[1]
    {
      "external_id" => user_id,
      @attribute_name => attribute_value
    }
  end

  def headers
    { 'Content-Type' => 'application/json' }
  end
end

AttributeExporter.new.send_if_confirmed