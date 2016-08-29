class CarwashLocator
  MAX_DISTANCE = 3000

  def self.nearest(coordinates)
    washes = Carwash.with_coordinates

    washes.select { |wash| wash.distance_to(coordinates) < MAX_DISTANCE }
  end
end


----------------------------------------------------------------------------------------


require "rails_helper"

describe CarwashLocator do
  describe ".nearest" do
    let(:carwash) { create :carwash }
    let(:carwash_far_away) { create :carwash }
    let(:coordinates) { [123.45, 987.65] }

    subject { described_class.nearest(coordinates) }

    before do
      allow(Carwash).to receive(:with_coordinates).and_return [carwash, carwash_far_away]
      allow(carwash).to receive(:distance_to).with(coordinates).and_return 2000
      allow(carwash_far_away).to receive(:distance_to).with(coordinates).and_return 4000
    end

    it { is_expected.to match_array [carwash] }
  end
end
