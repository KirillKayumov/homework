class Book
  def file_url
    "/system/#{path_prefix}/#{filename}"
  end

  def delete_file
    self.filename = nil
    self.file_destroyed_at = Time.now
    save
  end

  private

  def path_prefix
    filename[0..1].downcase
  end
end


----------------------------------------------------------------------------------------


require "rails_helper"

describe Book do
  describe "#file_url" do
    let(:book) { build :book, :filename => "AWESOME_name.txt" }

    subject { book.file_url }

    it { is_expected.to eq "/system/aw/AWESOME_name.txt" }
  end

  describe "#delete_file" do
    let(:book) { build :book, :filename => "awesome_name.txt", :file_destroyed_at => nil }
    let(:now) { Time.now }

    subject(:delete_file) { book.delete_file }

    before do
      allow(Time).to receive(:now).and_return(now)
    end

    it { is_expected.to change { book.reload.filename }.from("awesome_name.txt").to(nil) }
    it { is_expected.to change { book.reload.file_destroyed_at }.from(nil).to(now) }
  end
end
