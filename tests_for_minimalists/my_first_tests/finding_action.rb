class FindingAction
  belongs_to :creator

  def notify_creator(updater)
    FindingActionNotifier.send_creator_notification(self) if should_notify_creator?(updater)
  end

  private

  def should_notify_creator?(updater)
    updater != creator && NotificationsManager.allows_notifying?(updater)
  end
end


----------------------------------------------------------------------------------------


require "rails_helper"

describe FindingAction do
  describe "#notify_creator" do
    let(:updater) { build :user }
    let(:creator) { build :user }
    let(:finding_action) { build :finding_action, :creator => creator, :updater => updater }

    subject(:notify_creator) { finding_action.notify_creator(updater) }

    before do
      allow(NotificationsManager).to receive(:allows_notifying?).with(updater).and_return(true)
    end

    it "notifies creator" do
      expect(FindingActionNotifier).to receive(:send_creator_notification).with(finding_action)

      notify_creator
    end

    context "when updater == creator" do
      let(:finding_action) { build :finding_action, :creator => creator, :updater => creator }

      it "does NOT notify creator" do
        expect(FindingActionNotifier).not_to receive(:send_creator_notification)

        notify_creator
      end
    end

    context "when notifications for updater are disabled" do
      before do
        allow(NotificationsManager).to receive(:allows_notifying?).with(updater).and_return(false)
      end

      it "does NOT notify creator" do
        expect(FindingActionNotifier).not_to receive(:send_creator_notification)

        notify_creator
      end
    end
  end
end
