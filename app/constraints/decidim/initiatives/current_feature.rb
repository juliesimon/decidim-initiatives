# frozen_string_literal: true

module Decidim
  module Initiatives
    # This class infers the current feature on an assembly context
    # request parameters and injects it into the environment.
    class CurrentFeature
      # Public: Initializes the class.
      #
      # manifest - The manifest of the feature to check against.
      def initialize(manifest)
        @manifest = manifest
      end

      # Public: Matches the request against a feature and injects it into the
      #         environment.
      #
      # request - The request that holds the current feature relevant information.
      #
      # Returns a true if the request matches an assembly and a
      # feature belonging to that assembly, false otherwise
      def matches?(request)
        CurrentInitiative.new.matches?(request) &&
          Decidim::CurrentFeature.new(@manifest).matches?(request)
      end
    end
  end
end
