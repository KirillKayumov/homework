class User
  before_validation :set_access_token

  def date_format
    super.presence || "%d.%m.%Y"
  end

  private

  def set_access_token
    self.access_token ||= SecureRandom.uuid
  end
end


----------------------------------------------------------------------------------------


require "rails_helper"

describe User do
  describe "validations" do
    describe "#set_access_token" do
      let(:user) { build :user }

      before do
        allow(SecureRandom).to receive(:uuid).and_return("super_secret")
      end

      it "sets access token" do
        expect { user.valid? }.to change { user.access_token }.from(:nil).to("super_secret")
      end

      context "when user has access token" do
        let(:user) { build :user, :access_token => "top_secret" }

        specify do
          expect { user.valid? }.not_to change { user.access_token } }
        end
      end
    end
  end

  describe "#date_format" do
    let(:user) { build :user, :date_format => "%Y/%m/%d" }

    subject { user.date_format }

    it { is_expected.to eq "%Y/%m/%d" }

    context "when user has blank date_format" do
      let(:user) { build :user, :date_format => "" }

      it { is_expected.to eq "%d.%m.%Y" }
    end
  end
end
