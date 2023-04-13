require 'cached_request'

RSpec.describe CachedRequest do
  include_context 'http_response'

  subject do
    CachedRequest.new(uri_string: 'http://fake/uri', cache_key: 'cache_key')
  end

  describe '#initialize' do
    it 'instantiates the object' do
      expect(subject.is_a?(CachedRequest)).to eq true
    end
  end

  describe '#cached' do
    it 'returns nil before a call is made' do
      expect(subject.cached).to be_nil
    end

    context 'after a get call has been made' do
      it 'returns true if that call hit the cache' do
        expect(Rails.cache).to receive(:fetch).and_return('response_body')

        result = subject.get

        expect(subject.cached).to eq true
        expect(result).to eq 'response_body'
      end

      it 'returns false after a cache miss and subsequent API call' do
        expect(Net::HTTP).to receive(:get_response).and_return(http_mock_get_response)

        result = subject.get

        expect(subject.cached).to eq false
        expect(result).to eq 'response_body'
      end
    end
  end

  describe '#get' do
    context 'the request has not yet been cached' do
      let(:response_mock) { http_mock_get_response }

      before do
        expect(Net::HTTP).to receive(:get_response).and_return(response_mock)
      end

      context 'the request is good' do
        it 'successfully returns the body of the response' do
          expect(subject.get).to eq 'response_body'
        end

        context 'the request is cached' do
          # enable caching (disabled by default for tests)
          let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

          # Freeze time to 2:30 PM (UTC) the day the project started and test data is from
          let(:today)    { Time.parse("2023-04-11T14:30:00+00:00") }
          let(:tomorrow) { Time.parse("2023-04-12T14:30:00+00:00") }
          let(:time_freeze) { today }

          before do
            Timecop.freeze(time_freeze)

            allow(Rails).to receive(:cache).and_return(memory_store)
            Rails.cache.clear

            # perform the first request (against mocks) to store the result in cache
            subject.get
          end

          after do
            Timecop.return
          end

          it 'successfully re-reads the value from the cache without hitting the API' do
            # make sure we don't call an HTTP request after using the mocks
            expect(Net::HTTP).to_not receive(:get_response)

            expect(subject.get).to eq 'response_body'
          end

          context 'time has elapsed beyond the cache retention duration' do
            before do
              Timecop.freeze(tomorrow)
            end

            it 'calls the API again if the cache has timed out' do
              allow(response_mock).to receive(:body).and_return 'new_response_body'
              expect(Net::HTTP).to receive(:get_response).and_return response_mock

              expect(subject.get).to eq 'new_response_body'
            end
          end
        end
      end

      context 'the remote request fails' do
        let(:response_success) { false }

        it 'throws an exception containing the full response' do
          thrown_error = nil
          expect {
            subject.get
          }.to raise_error(CachedRequest::CachedHttpGetException) { |error|
            expect(error.response).to be response_mock
          }
        end
      end
    end
  end

  describe '#result' do
    it 'returns nil if there has not yet been a call' do
      expect(subject.result).to be_nil
    end

    it 'gets the value of the most recent request' do
      response_mock = http_mock_get_response
      expect(Net::HTTP).to receive(:get_response).and_return response_mock
      subject.get
      expect(subject.result).to be response_mock
    end
  end
end
