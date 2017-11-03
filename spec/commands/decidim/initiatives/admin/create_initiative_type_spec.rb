# frozen_string_literal: true

require 'spec_helper'

module Decidim
  module Initiatives
    module Admin
      describe CreateInitiativeType do
        let(:form_klass) { InitiativeTypeForm }

        describe 'successfull creation' do
          it_behaves_like 'create an initiative type', true
        end

        describe 'Validation failure' do
          let(:organization) { create(:organization) }
          let!(:initiative_type) do
            create(:initiatives_type, organization: organization)
          end
          let(:form) {
            form_klass
              .from_model(initiative_type)
              .with_context(current_organization: organization)
          }

          let(:errors) do
            ActiveModel::Errors.new(initiative_type)
              .tap { |e| e.add(:banner_image, 'upload error') }
          end
          let(:command) { described_class.new(form) }

          it 'broadcasts invalid' do
            expect_any_instance_of(InitiativesType).to receive(:persisted?)
                                                         .at_least(:once)
                                                         .and_return(false)

            expect { command.call }.to broadcast :invalid
          end
        end
      end
    end
  end
end