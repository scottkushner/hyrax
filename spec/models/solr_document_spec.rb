RSpec.describe ::SolrDocument, type: :model do
  let(:document) { described_class.new(attributes) }
  let(:attributes) { {} }

  describe "#itemtype" do
    let(:attributes) { { resource_type_tesim: ['Article'] } }
    it "delegates to the Hyrax::ResourceTypesService" do
      expect(Hyrax::ResourceTypesService).to receive(:microdata_type).with('Article')
      subject
    end
    subject { document.itemtype }
    it { is_expected.to eq 'http://schema.org/Article' }
  end

  describe "date_uploaded" do
    let(:attributes) { { 'date_uploaded_dtsi' => '2013-03-14T00:00:00Z' } }
    subject { document.date_uploaded }
    it { is_expected.to eq Date.parse('2013-03-14') }

    context "when an invalid type is provided" do
      let(:attributes) { { 'date_uploaded_dtsi' => 'Test' } }
      it "logs parse errors" do
        expect(ActiveFedora::Base.logger).to receive(:info).with(/Unable to parse date.*/)
        subject
      end
    end
  end

  describe "rights_statement" do
    let(:attributes) { { 'rights_statement_tesim' => ['A rights statement'] } }

    it "responds to rights_statement" do
      expect(document).to respond_to(:rights_statement)
    end
    it "returns the proper data" do
      expect(document.rights_statement).to eq ['A rights statement']
    end
  end

  describe "create_date" do
    let(:attributes) { { 'system_create_dtsi' => '2013-03-14T00:00:00Z' } }
    subject { document.create_date }
    it { is_expected.to eq Date.parse('2013-03-14') }

    context "when an invalid type is provided" do
      let(:attributes) { { 'system_create_dtsi' => 'Test' } }
      it "logs parse errors" do
        expect(ActiveFedora::Base.logger).to receive(:info).with(/Unable to parse date.*/)
        subject
      end
    end
  end

  describe "resource_type" do
    let(:attributes) { { 'resource_type_tesim' => ['Image'] } }
    subject { document.resource_type }
    it { is_expected.to eq ['Image'] }
  end

  describe "thumbnail_path" do
    let(:attributes) { { 'thumbnail_path_ss' => ['/foo/bar'] } }

    subject { document.thumbnail_path }

    it { is_expected.to eq '/foo/bar' }
  end

  describe '#to_param' do
    let(:id) { '1v53kn56d' }
    let(:attributes) { { id: id } }
    subject { document.to_param }
    it { is_expected.to eq id }
  end

  describe "#suppressed?" do
    let(:attributes) { { 'suppressed_bsi' => suppressed_value } }
    subject { document }
    context 'when true' do
      let(:suppressed_value) { true }
      it { is_expected.to be_suppressed }
    end
    context 'when false' do
      let(:suppressed_value) { false }
      it { is_expected.not_to be_suppressed }
    end
  end
  describe "document types" do
    class Mimes
      include Hydra::Works::MimeTypes
    end

    Mimes.office_document_mime_types.each do |type|
      context "when mime-type is #{type}" do
        let(:attributes) { { 'mime_type_ssi' => type } }
        subject { document }
        it { is_expected.to be_office_document }
      end
    end

    Mimes.video_mime_types.each do |type|
      context "when mime-type is #{type}" do
        let(:attributes) { { 'mime_type_ssi' => type } }
        subject { document }
        it { is_expected.to be_video }
      end
    end
  end

  describe '#collection_ids' do
    subject { document.collection_ids }
    context 'when the object belongs to collections' do
      let(:attributes) do
        { id: '123',
          title_tesim: ['A generic work'],
          collection_ids_tesim: ['123', '456', '789'] }
      end
      it { is_expected.to eq ['123', '456', '789'] }
    end

    context 'when the object does not belong to any collections' do
      let(:attributes) do
        { id: '123',
          title_tesim: ['A generic work'] }
      end

      it { is_expected.to eq [] }
    end
  end

  describe '#collections' do
    subject { document.collections }
    context 'when the object belongs to a collection' do
      let(:coll_id) { '456' }
      let(:attributes) do
        { id: '123',
          title_tesim: ['A generic work'],
          collection_ids_tesim: [coll_id] }
      end

      let(:coll_attrs) { { id: coll_id, title_tesim: ['A Collection'] } }

      before do
        ActiveFedora::SolrService.add(coll_attrs)
        ActiveFedora::SolrService.commit
      end

      it 'returns the solr docs for the collections' do
        expect(subject.count).to eq 1
        solr_doc = subject.first
        expect(solr_doc).to be_kind_of described_class
        expect(solr_doc['id']).to eq coll_id
        expect(solr_doc['title_tesim']).to eq coll_attrs[:title_tesim]
      end
    end

    context 'when the object does not belong to any collections' do
      it { is_expected.to eq [] }
    end
  end

  describe "#height" do
    let(:attributes) { { height_is: '444' } }
    subject { document.height }
    it { is_expected.to eq '444' }
  end

  describe "#width" do
    let(:attributes) { { width_is: '555' } }
    subject { document.width }
    it { is_expected.to eq '555' }
  end

  context "when exporting in endnote format" do
    let(:attributes) { { id: "1234" } }
    subject { document.endnote_filename }
    it { is_expected.to eq("1234.endnote") }
  end
end
