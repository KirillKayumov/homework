class RisksController
  def update_from_origin
    SourceTrackableUpdater.new(trackable_resource).update_from_origin

    redirect_to trackable_resource
  end
end


----------------------------------------------------------------------------------------


require "rails_helper"

describe RisksController do
  describe "PUT #update_from_origin" do
    let(:trackable_resource) { ... }
    let(:fake_updater) { double(:updater, :update_from_origin => true) }

    def do_request
      ...
    end

    before do
      allow(SourceTrackableUpdater).to receive(:new).with(trackable_resource).and_return(fake_updater)
    end

    it "calls SourceTrackableUpdater" do
      expect(fake_updater).to receive(:update_from_origin)

      do_request
    end
  end
end
