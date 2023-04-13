require 'cached_request'

RSpec.describe ForecastController, type: :controller do
  include_context 'geocoder_samples'
  include_context 'http_response'

  describe 'Routes' do
    it { expect(get: root_path).to route_to 'forecast#index' }
    it { expect(get: forecast_index_path).to route_to 'forecast#index' }
    it { expect(get: forecast_url(':query')).to route_to 'forecast#show', query: ':query' }
    it { expect(post: search_url(':query')).to route_to 'forecast#search', param: :query, format: ':query' }
  end

  describe 'GET /index' do
    it 'renders the page' do
      get :index

      expect(response).to be_successful
      expect(response.status).to eq 200
    end
  end

  describe 'POST /search' do
    before do
      expect(Geocoder).to receive(:search).with(query).and_return geocoder_location
    end

    context 'when searching for "Empire State Building"' do
      let(:query) { 'Empire State Building' }
      let(:geocoder_location) { @geocoder_empire_state_building }

      it 'takes the happy path and redirects to the show page' do
        post :search, params: { param: :query, query: query }

        expect(response).to redirect_to(forecast_url('new_york-10118'))
      end
    end

    context 'when the system is down and/or no location is found' do
      let(:query) { 'bad data' }
      let(:geocoder_location) { @geocoder_empty }

      it 'redirects to the home page with a "failure to query" message' do
        post :search, params: { param: :query, query: query }

        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to start_with 'Failed to query location'
      end
    end

    context 'when a location is returned but it does not have useful data' do
      let(:query) { 'Nowhere Land' }
      let(:geocoder_location) { @geocoder_blank }

      it 'redirects to the home page with a "Couldn\'t resolve" message' do
        post :search, params: { param: :query, query: query }

        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to eq "Couldn't resolve the given location: \"#{query}\"."
      end
    end
  end

  describe 'GET /show' do
    let(:query) { 'seattle-98121' }

    context 'a valid forecast is loaded' do
      before do
        response_mock = http_mock_get_response(http_get_sample_weather_api)
        expect(Net::HTTP).to receive(:get_response).and_return(response_mock)
      end

      it 'sends the forecast to render' do
        get :show, params: { param: :query, query: query }

        forecast = assigns(:forecast)
        expect(forecast).to_not be_nil
        expect(forecast.data.days.first.icon).to eq 'rain'
      end
    end

    context 'the weather API fails and throws an exception' do
      before do
        expect(Net::HTTP).to receive(:get_response).and_return(http_mock_get_response)
      end

      let(:response_success) { false }

      it 'redirects to the root path with a "Failed to load" message' do
        get :show, params: { param: :query, query: 'seattle-98121' }

        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to start_with "Failed to load forecast data"
      end
    end
  end

  describe '#geolocation_to_post_key' do
    it 'properly constructs a normal key' do
      result = subject.send(:geolocation_to_post_key, @geocoder_seattle.first)
      expect(result).to eq 'seattle-98121'
    end

    it 'replaces underscores in city names' do
      result = subject.send(:geolocation_to_post_key, @geocoder_empire_state_building.first)
      expect(result).to eq 'new_york-10118'
    end

    it 'replaces underscores in post codes - also ensure downcasing post codes' do
      result = subject.send(:geolocation_to_post_key, @geocoder_potato_wharf.first)
      expect(result).to eq 'manchester-m3_4'
    end

    it 'gives just the city if no post code is present' do
      result = subject.send(:geolocation_to_post_key, @geocoder_seattle_no_post.first)
      expect(result).to eq 'seattle'
    end
  end
end
