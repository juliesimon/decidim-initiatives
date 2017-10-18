# frozen_string_literal: true

module Decidim
  module Initiatives
    # Exposes the initiative type text search so users can choose a type writing its name.
    class InitiativesTypeScopesController < Decidim::ApplicationController
      skip_before_action :store_current_location

      helper_method :scoped_types

      def search
        authorize! :search, InitiativesTypeScope
        render layout: false
      end

      private

      def scoped_types
        @scoped_types ||= InitiativesType.find(params[:type_id]).scopes
      end
    end
  end
end