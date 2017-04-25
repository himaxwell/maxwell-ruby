require "spec_helper"

describe Maxwell::Client do
  before do
    set_config
    WebMock.disable_net_connect!
  end

  describe ".authenticate" do
    let(:args) { { email: 'example@example.com', password: 'password' } }

    before do
      stub_request(:post, "https://example.com/api/auth").
         with(:body => "{\"email\":\"example@example.com\",\"password\":\"password\"}",
              :headers => {'Accept'=>'application/vnd.himaxwell.com; version=1,application/json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
         to_return(:status => 204, :body => {token: 'sometoken'}.to_json, :headers => {})
    end

    subject { described_class.authenticate(args) }

    it "returns a jwt" do
      expect(subject.body).to eq "{\"token\":\"sometoken\"}"
    end

    it "returns the correct response status" do
      expect(subject.code).to eq "204"
    end
  end

  describe ".get" do
    before do
      stub_request(:get, "https://example.com/api/loan_files/active_loan_volume").
         with(:headers => {'Accept'=>'application/vnd.himaxwell.com; version=1,application/json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer sometoken', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => "{\"active_loan_volume\":\"$0.00\"}", :headers => {})
    end

    let(:path) { '/loan_files/active_loan_volume' }
    let(:opts) { { token: 'sometoken'           } }

    subject { described_class.get(path, opts) }

    it "returns a valid response" do
      expect(subject.body).to eq "{\"active_loan_volume\":\"$0.00\"}"
    end

    it "returns the correct response status" do
      expect(subject.code).to eq "200"
    end
  end

  describe ".post" do
    before do
      stub_request(:post, "https://example.com/api/loan_files").
         with(:body => "null",
              :headers => {'Accept'=>'application/vnd.himaxwell.com; version=1,application/json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer sometoken', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
         to_return(:status => 204, :body => "{\"loanFiles\":[]}", :headers => {})
    end

    let(:path) { '/loan_files'          }
    let(:opts) { { token: 'sometoken' } }

    subject { described_class.post(path, opts) }

    it "returns a valid response" do
      expect(subject.body).to eq "{\"loanFiles\":[]}"
    end

    it "returns the correct response status" do
      expect(subject.code).to eq "204"
    end
  end

  describe ".put" do
    before do
      stub_request(:put, "https://example.com/api/loan_files/1").
         with(body: "null",
              headers: {'Accept'=>'application/vnd.himaxwell.com; version=1,application/json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer sometoken', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
         to_return(status: 200, body: "{\"id\":1}", headers: {})
    end

    let(:path) { '/loan_files/1'        }
    let(:opts) { { token: 'sometoken' } }

    subject { described_class.put(path, opts) }

    it "returns a valid response" do
      expect(subject.body).to eq "{\"id\":1}"
    end

    it "returns the correct response status" do
      expect(subject.code).to eq "200"
    end
  end

  describe ".delete" do
    before do
      stub_request(:delete, "https://example.com/api/loan_files/1").
         with(body: "null",
              headers: {'Accept'=>'application/vnd.himaxwell.com; version=1,application/json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer sometoken', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
         to_return(status: 200, body: "{\"id\":1}", headers: {})
    end

    let(:path) { '/loan_files/1'        }
    let(:opts) { { token: 'sometoken' } }

    subject { described_class.delete(path, opts) }

    it "returns a valid response" do
      expect(subject.body).to eq "{\"id\":1}"
    end

    it "returns the correct response status" do
      expect(subject.code).to eq "200"
    end
  end

  describe "#perform" do
    subject { described_class.new(args) }

    context "with no token or jwt" do
      let(:args) do
        {
          jwt: nil,
          token: nil,
          request_method: :get,
          endpoint: '/loan_files/active_loan_volume',
        }
      end

      it "raises an exception" do
        expect{subject.perform}.to raise_error(
          Maxwell::UnauthorizedRequest,
          'Please supply an API key in an initializer or Token with your request',
        )
      end
    end

    context "with token" do
      before do
        stub_request(:get, "https://example.com/api/loan_files/active_loan_volume").
          with(:headers => {'Accept'=>'application/vnd.himaxwell.com; version=1,application/json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Token apikey', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => "{\"active_loan_volume\":\"$0.00\"}", :headers => {})

      end

      let(:args) do
        {
          jwt: nil,
          token: 'apikey',
          request_method: :get,
          endpoint: '/loan_files/active_loan_volume',
        }
      end

      it "performs the request" do
        expect(subject.perform).to be_instance_of(Net::HTTPOK)
      end
    end

    context "with jwt" do
      before do
        stub_request(:get, "https://example.com/api/loan_files/active_loan_volume").
          with(:headers => {'Accept'=>'application/vnd.himaxwell.com; version=1,application/json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer sometoken', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => "{\"active_loan_volume\":\"$0.00\"}", :headers => {})
      end

      let(:args) do
        {
          jwt: 'sometoken',
          token: nil,
          request_method: :get,
          endpoint: '/loan_files/active_loan_volume',
        }
      end

      it "performs the request" do
        expect(subject.perform).to be_instance_of(Net::HTTPOK)
      end
    end
  end
end
