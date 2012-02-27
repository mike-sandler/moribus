module Core
  module Behaviors
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload

    autoload :AggregatedBehavior
    autoload :TrackedBehavior
    autoload :BelongsToAssociationPatch
    autoload :HasOneAssociationPatch

    included do
      ActiveRecord::Associations::BelongsToAssociation.send(:include, BelongsToAssociationPatch)
      ActiveRecord::Associations::HasOneAssociation.send(:include, HasOneAssociationPatch)
    end

    def new_recordify
      @_id_before_new_recodify = id
      self.id = nil
      @new_record = true
    end

    def persistentify(existing = nil)
      if existing
        self.id         = existing.id
        self.created_at = existing.created_at if respond_to?(:created_at)
        self.updated_at = existing.updated_at if respond_to?(:updated_at)
        @changed_attributes = {}
      else
        self.id = @_id_before_new_recordify
      end
      @new_record = false
      true
    end

    def updated_as_aggregated?
      !!@updated_as_aggregated
    end

    def tracked?
      false
    end

    module ClassMethods
      def aggregated
        include AggregatedBehavior
      end

      def tracked
        include TrackedBehavior
      end

      def represented_by(name, options = {})
        has_one name, options.merge(:conditions => {:is_current => true})
        accepts_nested_attributes_for name
      end

      def consists_of(*parts)
        parts.each do |name|
          belongs_to name
          accepts_nested_attributes_for name
        end
      end
    end
  end
end