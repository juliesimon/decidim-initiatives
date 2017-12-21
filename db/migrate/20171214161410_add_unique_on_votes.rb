# This migration comes from decidim_initiatives (originally 20171214161410)
# frozen_string_literal: true

class AddUniqueOnVotes < ActiveRecord::Migration[5.1]
  def get_duplicates(*columns)
    Decidim::InitiativesVote.select("#{columns.join(',')}, COUNT(*)").group(columns).having('COUNT(*) > 1')
  end

  def row_count(issue)
    Decidim::InitiativesVote.where(
      decidim_initiative_id: issue.decidim_initiative_id,
      decidim_author_id: issue.decidim_author_id,
      decidim_user_group_id: issue.decidim_user_group_id
    ).count
  end

  def find_next(issue)
    Decidim::InitiativesVote.find_by(
      decidim_initiative_id: issue.decidim_initiative_id,
      decidim_author_id: issue.decidim_author_id,
      decidim_user_group_id: issue.decidim_user_group_id
    )
  end

  def up
    columns = %i[decidim_initiative_id decidim_author_id decidim_user_group_id]

    get_duplicates(columns).each do |issue|
      while row_count(issue) > 1 do
        find_next(issue)&.destroy
      end
    end


    add_index :decidim_initiatives_votes,
              columns,
              unique: true,
              name: 'decidim_initiatives_voutes_author_uniqueness_index'
  end
end