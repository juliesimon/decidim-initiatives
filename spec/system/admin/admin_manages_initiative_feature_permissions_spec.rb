# frozen_string_literal: true

require "spec_helper"
require "decidim/admin/test/manage_feature_permissions_examples"

describe "Admin manages initiative feature permissions", type: :system do
  include_examples "Managing feature permissions" do
    let(:user) { create(:user, :admin, :confirmed, organization: organization) }
    let(:participatory_space_engine) { decidim_admin_initiatives }

    let!(:participatory_space) do
      create(:initiative, organization: organization)
    end
  end
end
