class BatchSectionClone
  def self.clone(sections, target)
    sections.map do |section|
      SectionClone.new(section, target).clone
    end
  end
end


----------------------------------------------------------------------------------------


require "rails_helper"

describe BatchSectionClone do
  describe ".clone" do
    let(:target) { create :audit }
    let(:sections) { create_list :section, 5 }
    let(:fake_cloner) { double :cloner, :clone => true }

    subject(:clone) { described_class.clone(sections, target) }

    before do
      allow(SectionClone).to receive(:new).with(kind_of(Section), target).and_return(fake_cloner)
    end

    it "calls SectionClone for every section" do
      expect(fake_cloner).to receive(:clone).exactly(5).times

      clone
    end
  end
end
