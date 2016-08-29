class TodoAssigneeNotifier
  def self.notify(todo)
    if NotificationManager.allows_notifying_membership?(todo.executor)
      TodoMailer.todo_notification(todo)
    end

    PushNotification.deliver("todo_assign", todo.executor, todo)
  end
end


----------------------------------------------------------------------------------------


require "rails_helper"

describe TodoAssigneeNotifier do
  describe ".notify" do
    let(:executor) { create :user }
    let(:todo) { create :todo, :executor => executor }

    subject(:notify) { described_class.notify(todo) }

    it "calls PushNotification" do
      expect(PushNotification).to receive(:deliver).with("todo_assign", executor, todo)

      notify
    end

    it "calls TodoMailer" do
      expect(TodoMailer).to receive(:todo_notification).with(todo)

      notify
    end

    context "when executor has disabled membership notifications" do
      before do
        allow(NotificationManager).to receive(:allows_notifying_membership?).with(executor).and_return(false)
      end

      it "does NOT call TodoMailer" do
        expect(TodoMailer).not_to receive(:todo_notification)

        notify
      end
    end
  end
end
