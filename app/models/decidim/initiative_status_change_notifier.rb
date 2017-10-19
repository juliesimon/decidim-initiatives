# frozen_string_literal: true

module Decidim
  class InitiativeStatusChangeNotifier
    attr_reader :initiative

    def initialize(args = {})
      @initiative = args.fetch(:initiative)
    end

    def notify
      notify_validating_initiative if initiative.validating?

      if initiative.published? || initiative.discarded?
        notify_validating_result
      end

      if initiative.rejected? || initiative.accepted?
        notify_support_result
      end
    end

    private

    def notify_validating_initiative
      initiative.organization.admins.each do |user|
        Decidim::Initiatives::InitiativesMailer
          .notify_validating_request(initiative, user)
          .deliver_later
      end
    end

    def notify_validating_result
      initiative.committee_members.approved.each do |committee_member|
        Decidim::Initiatives::InitiativesMailer
          .notify_state_change(initiative, committee_member.user)
          .deliver_later
      end

      Decidim::Initiatives::InitiativesMailer
        .notify_state_change(initiative, initiative.author)
        .deliver_later
    end

    def notify_support_result
      initiative.followers.each do |follower|
        Decidim::Initiatives::InitiativesMailer
          .notify_state_change(initiative, follower)
          .deliver_later
      end

      initiative.committee_members.approved.each do |committee_member|
        Decidim::Initiatives::InitiativesMailer
          .notify_state_change(initiative, committee_member.user)
          .deliver_later
      end

      Decidim::Initiatives::InitiativesMailer
        .notify_state_change(initiative, initiative.author)
        .deliver_later
    end
  end
end