RSpec.shared_context 'http_response' do

  # internal helper for setting up a generic mock HTTP response
  def http_mock_get_response(response_body='response_body')
    response_mock = double(Net::HTTPResponse)
    allow(response_mock).to receive(:is_a?).with(Net::HTTPSuccess).and_return response_success
    allow(response_mock).to receive(:body).and_return response_body
    response_mock
  end

  let(:response_success) { true }

  # helper to load test data from the weather api
  def http_get_sample_weather_api
    File.read('./spec/support/weather_data_get.json')
  end
end
