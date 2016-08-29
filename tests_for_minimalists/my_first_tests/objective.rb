class Objective
  LOCK_STATUSES = {
    :unlocked  => 0,
    :uploading => 1,
    :locked    => 2
  }

  def locked?
    locked_by.present? &&
    [LOCK_STATUSES[:uploading], LOCK_STATUSES[:locked]].include?(lock_status)
  end

  def release_lock
    assign_attributes(
      :locked_by => nil,
      :locked_on_name => nil,
      :locked_on_id => nil,
      :lock_status => LOCK_STATUSES[:unlocked]
    )
  end
end


----------------------------------------------------------------------------------------


require "rails_helper"

describe Objective do
  let(:user) { build :user }

  describe "#locked?" do
    subject { objective }

    context "when locked_by is blank" do
      let(:objective) { build :objective, :locked_by => nil, :lock_status => Objective::LOCK_STATUSES[:locked] }

      it { is_expected.not_to be_locked }
    end

    context "when lock_status is unlocked" do
      let(:objective) { build :objective, :locked_by => user, :lock_status => Objective::LOCK_STATUSES[:unlocked] }

      it { is_expected.not_to be_locked }
    end

    context "when locked_by is present" do
      context "and lock_status is uploading" do
        let(:objective) { build :objective, :locked_by => user, :lock_status => Objective::LOCK_STATUSES[:uploading] }

        it { is_expected.to be_locked }
      end

      context "and lock_status is locked" do
        let(:objective) { build :objective, :locked_by => user, :lock_status => Objective::LOCK_STATUSES[:locked] }

        it { is_expected.to be_locked }
      end
    end
  end

  describe "#release_lock" do
    let(:objective) do
      build :objective,
        :locked_by => user,
        :locked_on_name => "Kirill",
        :locked_on_id => 1,
        :lock_status => Objective::LOCK_STATUSES[:locked]
    end

    subject { objective.release_lock }

    it { is_expected.to change { objective.locked_by }.from(user).to(nil) }
    it { is_expected.to change { objective.locked_on_name }.from("Kirill").to(nil) }
    it { is_expected.to change { objective.locked_on_id }.from(1).to(nil) }
    it do
      is_expected.to change {
        objective.lock_status
      }.from(Objective::LOCK_STATUSES[:locked]).to(Objective::LOCK_STATUSES[:unlocked])
    end
  end
end
