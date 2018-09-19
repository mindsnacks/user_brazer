# gem install httparty

require 'csv'
require 'uri'
require 'httparty'

class BrazeNonUserCreator
  APPBOY_URL = 'https://api.appboy.com/users/track'
  FILE_NAME = 'emails_to_import.csv'
  SUBSCRIBED_STRING = "subscribed"
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  IMPORT_ATTRIBUTE = 'import_cohort.' + Time.now.strftime("%Y-%m-%d_%H:%M:%S")

  def initialize
    full_array_of_emails = CSV.read(FILE_NAME, "r:ISO-8859-1")

    @array_count = full_array_of_emails.length
    @array_of_ids = full_array_of_emails.each_slice(50).to_a
    puts "Is emails_to_import.csv full of valid email addresses without a header? (y/n)"
    if gets.chomp == "y"
      puts "Importing new emails into Braze non-user group"
      batch_send_attributes
    else
      puts "Please fix emails_to_import.csv and run again."
    end
  end

  def appboy_non_user_app_group_id
    # We set up a separate app group for emails to recipients who are not yet users,
    # since Appboy requires an external ID to create a record
    ENV["APPBOY_NON_USER_APP_GROUP_ID"]
  end

  def batch_send_attributes
    count = 0
    @array_of_ids.each do |array_batch|
      array_of_attributes = []
      array_batch.each do |email_array|
        email = email_array[0]
        if email =~ VALID_EMAIL_REGEX
          count += 1
          array_of_attributes << user_attributes_object(email)
          sleep(0.001)
        end
      end
      attribute_payload = payload(array_of_attributes)
      response = call_appboy(attribute_payload)
      if response.code == 201
        puts("#{count} out of #{@array_count} users processed")
      else
        puts("Error:")
        puts(response)
      end
    end
    puts "#{count} users created with import attribute #{IMPORT_ATTRIBUTE}"
  end

  def user_attributes_object(email)
    user_id = (Time.now.utc.to_f * 1000).to_i
    {
      "external_id" => user_id,
      "email" => email,
      IMPORT_ATTRIBUTE => "TRUE"
    }
  end

  def payload(array_of_attributes)
    {
      "app_group_id" => appboy_non_user_app_group_id,
      "attributes" => array_of_attributes
    }
  end

  def update_user_information(user, app_group_id)
    params = {
      user: user
    }
    params[:app_group_id] = app_group_id if app_group_id
    parameter_wrapper = AppboyEventParameterWrapper.new(params)
    call_appboy(parameter_wrapper.body_with_attributes)
  end

  def create_new_non_user_in_appboy(email)
    non_user = AppboyNonUser.new(email)
    AppboyAPIInterface.new.update_user_information(non_user, appboy_non_user_app_group_id)
    non_user
  end

  private

  def call_appboy(body)
    HTTParty.post(APPBOY_URL, body: body.to_json, headers: default_headers)
  end

  def default_headers
    {'Content-Type' => 'application/json'}
  end
end

BrazeNonUserCreator.new