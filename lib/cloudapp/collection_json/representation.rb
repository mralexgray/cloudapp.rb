require 'delegate'
require 'ostruct'

module CloudApp
  module CollectionJson
    class Representation < SimpleDelegator
      def initialize(representation)
        super
      end

      def href
        collection.fetch('href')
      end

      def collection_links
        return [] unless collection.has_key?('links')
        collection.fetch('links').map {|link| OpenStruct.new(link) }
      end

      def items(item_source = default_item_source)
        collection.fetch('items').map do |item|
          item_source.call(item)
        end
      end

      # # Ultimately this API would be nice.
      # root.template(email: email, password: password).
      #   post do |response|
      #     return response
      #   end
      def template(template_source = default_template_source)
        return unless collection.has_key?('template')
        template_source.call collection.fetch('template')
      end

    protected

      def default_item_source
        CloudApp::CollectionJson::Item.public_method(:new)
      end

      def default_template_source
        CloudApp::CollectionJson::Template.public_method(:new)
      end

      def collection
        self.fetch('collection')
      end
    end
  end
end
