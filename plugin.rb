# frozen_string_literal: true

# name: discourse-education-category-custom-field
# about: Add a custom field to a category
# version: 0.1
# author: Angus McLeod

enabled_site_setting :category_custom_field_enabled
register_asset 'stylesheets/common.scss'

## 
# type:        introduction
# title:       Add a custom field to a category
# description: To get started, load the [discourse-category-custom-fields](https://github.com/pavilionedu/discourse-category-custom-fields)
#              plugin in your local development environment. Once you've got it
#              working, follow the steps below and in the client "initializer"
#              to understand how it works. For more about the context behind
#              each step, follow the links in the 'references' section.
##

after_initialize do
  FIELD_NAME ||= SiteSetting.category_custom_field_name
  FIELD_TYPE ||= SiteSetting.category_custom_field_type

  ## 
  # type:        step
  # number:      1
  # title:       Register the field
  # description: Where we tell discourse what kind of field we're adding. You
  #              can register a string, integer, boolean or json field.
  # references:  lib/plugins/instance.rb,
  #              app/models/concerns/has_custom_fields.rb
  ##
  register_category_custom_field_type(FIELD_NAME, FIELD_TYPE.to_sym)

  ##
  # type:        step
  # number:      2
  # title:       Add getter and setter methods
  # description: Adding getter and setter methods is optional, but advisable.
  #              It means you can handle data validation or normalisation, and
  #              it lets you easily change where you're storing the data. 
  #              However, unlike topic custom fields, for category custom
  #              fields the setter method won't be used in the standard
  #              implementation as custom_fields are created and updated
  #              directly on the category model. See further in step 3.
  ##

  ##
  # type:        step
  # number:      2.1
  # title:       Getter method
  # references:  lib/plugins/instance.rb,
  #              app/models/category.rb,
  #              app/models/concerns/has_custom_fields.rb
  ##
  add_to_class(:category, FIELD_NAME.to_sym) do
    if !custom_fields[FIELD_NAME].nil?
      custom_fields[FIELD_NAME]
    else
      nil
    end
  end

  ##
  # type:        step
  # number:      2.2
  # title:       Setter method
  # references:  lib/plugins/instance.rb,
  #              app/models/category.rb,
  #              app/models/concerns/has_custom_fields.rb
  ##
  add_to_class(:category, "#{FIELD_NAME}=") do |value|
    custom_fields[FIELD_NAME] = value
  end

  ##
  # type:        step
  # number:      3
  # title:       Update the field when the category is created or updated
  # description: In Discourse currently, category attributes are created and
  #              updated directly on the Category model. In both cases, any
  #              custom_fields passed to the relevant controller action will
  #              be created or updated directly as well. This means we don't
  #              need to add any handling for setting the field like we do
  #              with topic custom fields.
  # references:  app/controllers/categories_controller.rb,
  #              app/models/concerns/has_custom_fields.rb
  ##

  ##
  # type:        step
  # number:      4
  # title:       Serialize the field
  # description: Send our field to the client, along with the other category
  #              fields.
  ##

  ##
  # type:        step
  # number:      4.1
  # title:       Preload the field
  # description: Discourse preloads custom fields on listable models (i.e.
  #              categories or topics) before serializing them. This is to
  #              avoid running a potentially large number of SQL queries 
  #              ("N+1 Queries") at the point of serialization, which would
  #              cause performance to be affected.
  # references:  app/controllers/categories_controller.rb,
  #              app/models/concerns/has_custom_fields.rb
  ##
  Site.preloaded_category_custom_fields << FIELD_NAME

  ## 
  # type:        step
  # number:      4.2
  # title:       Serialize to the site categories
  # description: In most cases where a category is used, it's taken from a
  #              list of categories sent to the client on the Site model. This
  #              is sent when the Discourse client is first loaded. The
  #              SiteCategorySerializer is also the parent of the more detailed
  #              CategorySerializer which is used to load more attributes in
  #              the category edit interface.
  # references:  lib/plugins/instance.rb,
  #              app/serializers/site_category_serializer.rb,
  #              app/serializers/site_serializer.rb,
  #              app/serializers/category_serializer.rb
  ##
  add_to_serializer(:site_category, FIELD_NAME.to_sym) do
    object.send(FIELD_NAME)
  end
end