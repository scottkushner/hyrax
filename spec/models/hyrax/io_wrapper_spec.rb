RSpec.describe Hyrax::IoWrapper, type: :model do
  let(:path) { fixture_path + '/world.png' }
  subject { described_class.open(path) }

  it { is_expected.to be_a File }

  describe '#mime_type' do
    it 'extracts mime_type' do
      expect(subject.mime_type).to eq('image/png')
    end
    it 'can be overridden via accessor' do
      subject.mime_type = 'text/plain'
      expect(subject.mime_type).to eq('text/plain')
    end
    it 'uses original_name if set' do
      subject.original_name = '汉字.jpg'
      expect(subject.mime_type).to eq('image/jpeg')
      subject.original_name = 'no_suffix'
      expect(subject.mime_type).to eq('application/octet-stream')
    end
  end

  describe '#original_name' do
    it 'extracts original_name' do
      expect(subject.original_name).to eq('world.png')
    end
    it 'can be overridden via accessor' do
      subject.original_name = '汉字.jpg'
      expect(subject.original_name).to eq('汉字.jpg')
    end
  end

  # This is where Hydra::Derivatives::IoDecorator would fail
  describe '#==' do
    let(:other) { described_class.open(path) }
    it 'matches an identical IoWrapper' do
      expect(subject).to eq(other)
      expect(other).to eq(subject)
    end
    it 'does not match a similar File object' do # but doesn't throw exception either
      expect(subject).not_to eq(File.open(path))
      expect(File.open(path)).not_to eq(subject)
    end
  end
end
