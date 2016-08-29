class Risk
  def tag_list
    tags.to_s.split(",").map(&:strip)
  end

  def resolve_for=(period)
    case period
    when "one_month"
      resolve_until(1.month.from_now)
    when "one_year"
      resolve_until(1.year.from_now)
    when "permanently"
      self.resolved_until = nil
      self.resolved_permanently = true
    end
  end

  private

  def resolve_until(date)
    self.resolved_until = date
    self.resolved_permanently = false
  end
end


----------------------------------------------------------------------------------------


require "rails_helper"

describe Risk do
  describe "#tag_list" do
    let(:risk) { build :risk, :tags => " hip_hop,  basketball  , ruby " }

    subject { risk.tag_list }

    it { is_expected.to eq %w(hip_hop basketball ruby) }
  end

  describe "#resolve_for=" do
    let(:risk) { build :risk, :resolved_until => 1.day.ago, :resolved_permanently => true }
    let(:current_time) { Time.parse "2016/08/29" }

    subject(:assign_resolve_for) { risk.resolve_for = period }

    before do
      allow(Time).to receive(:current).and_return current_time
    end

    context "when period is one_month" do
      let(:period) { "one_month" }
      let(:since_one_month) { Time.parse "2016/09/29" }

      it { is_expected.to change { risk.resolved_until }.from(1.day.ago).to(since_one_month) }
      it { is_expected.to change { risk.resolved_permanently }.from(true).to(false) }
    end

    context "when period is one_year" do
      let(:period) { "one_year" }
      let(:since_one_year) { Time.parse "2017/08/29" }

      it { is_expected.to change { risk.resolved_until }.from(1.day.ago).to(since_one_year) }
      it { is_expected.to change { risk.resolved_permanently }.from(true).to(false) }
    end

    context "when period is permanently" do
      let(:period) { "permanently" }
      let(:risk) { build :risk, :resolved_until => 1.day.ago, :resolved_permanently => false }

      it { is_expected.to change { risk.resolved_until }.from(1.day.ago).to(nil) }
      it { is_expected.to change { risk.resolved_permanently }.from(false).to(true) }
    end
  end
end
