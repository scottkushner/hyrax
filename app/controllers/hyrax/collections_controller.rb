module Hyrax
  class CollectionsController < ApplicationController
    include CollectionsControllerBehavior
    include BreadcrumbsForCollections
    layout :decide_layout

    # Renders a JSON response with a list of files in this collection
    # This is used by the edit form to populate the thumbnail_id dropdown
    def files
      form = form_class.new(@collection)
      result = form.select_files.map do |label, id|
        { id: id, text: label }
      end
      render json: result
    end

    private

      def decide_layout
        case action_name
        when 'show'
          theme
        else
          'dashboard'
        end
      end
  end
end
