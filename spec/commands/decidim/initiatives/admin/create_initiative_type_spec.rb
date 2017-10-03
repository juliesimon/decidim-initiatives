# frozen_string_literal: true

require 'spec_helper'

module Decidim
  module Initiatives
    module Admin
      describe CreateInitiativeType do
        let(:form_klass) { InitiativeTypeForm }

        it_behaves_like 'create an initiative type', true
      end
    end
  end
end