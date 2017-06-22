module Hyrax
  module Forms
    class CollectionForm
      include HydraEditor::Form
      include HydraEditor::Form::Permissions

      delegate :id, :depositor, :permissions, to: :model

      self.model_class = ::Collection

      delegate :human_readable_type, :member_ids, to: :model

      self.terms = [:resource_type, :title, :creator, :contributor, :description,
                    :keyword, :license, :publisher, :date_created, :subject, :language,
                    :representative_id, :thumbnail_id, :identifier, :based_near,
                    :related_url, :visibility]

      self.required_fields = [:title]

      # @return [Hash] All FileSets in the collection, file.to_s is the key, file.id is the value
      def select_files
        Hash[all_files]
      end

      # Terms that appear above the accordion
      def primary_terms
        [:title]
      end

      # Terms that appear within the accordion
      def secondary_terms
        [:creator,
         :contributor,
         :description,
         :keyword,
         :license,
         :publisher,
         :date_created,
         :subject,
         :language,
         :identifier,
         :based_near,
         :related_url,
         :resource_type]
      end

      # Do not display additional fields if there are no secondary terms
      # @return [Boolean] display additional fields on the form?
      def display_additional_fields?
        secondary_terms.any?
      end

      def thumbnail_title
        return unless model.thumbnail
        model.thumbnail.title.first
      end

      private

        def all_files
          member_presenters.flat_map(&:file_set_presenters).map { |x| [x.to_s, x.id] }
        end

        def member_presenters
          PresenterFactory.build_for(ids: model.member_object_ids,
                                     presenter_class: WorkShowPresenter,
                                     presenter_args: [nil])
        end
    end
  end
end
