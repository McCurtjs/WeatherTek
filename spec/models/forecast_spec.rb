require 'forecast'

RSpec.describe Forecast do
  include_context 'http_response'

  subject do
    expect_any_instance_of(CachedRequest).to receive(:get).and_return(http_get_sample_weather_api)
    Forecast.new('test-location')
  end

  # Freeze time to 2:30 PM (UTC) the day the project started and test data is from
  let(:today)    { Time.parse("2023-04-11T14:30:00+00:00") }
  let(:tomorrow) { Time.parse("2023-04-12T14:30:00+00:00") }
  let(:time_freeze) { today }

  before { Timecop.freeze(time_freeze) }
  after { Timecop.return }

  describe '#initialize' do
    context 'the request during initialization fails' do
      before do
        expect_any_instance_of(CachedRequest).to receive(:get).and_raise(CachedRequest::CachedHttpGetException)
      end

      it 'lets the exception pass through' do
        expect {
          Forecast.new('test-location')
        }.to raise_error(CachedRequest::CachedHttpGetException)
      end
    end

    context 'the forecast is successfully initialized' do
      it 'reads and converts the data to an OpenStruct' do
        expect(subject.data.address).to eq('seattle')
        expect(subject.data.days.size).to eq(15)
      end
    end
  end

  describe '#cached' do
    it 'returns true when the request propagated true' do
      expect_any_instance_of(CachedRequest).to receive(:cached).and_return(true)
      expect(subject.cached).to eq true
    end

    it 'returns false when the request propagated false' do
      expect_any_instance_of(CachedRequest).to receive(:cached).and_return(false)
      expect(subject.cached).to eq false
    end
  end

  describe '#current_day' do
    it 'gets the object represnting the current day' do
      expect(subject.current_day).to be subject.data.days.first
    end

    context 'the current time is the day after the first day in a cached response' do
      let(:time_freeze) { tomorrow }

      it 'gets the object representing the second day' do
        expect(subject.current_day).to be subject.data.days.second
      end
    end
  end

  describe '#current_day_index' do
    it 'gets the index of the object represnting the current day' do
      expect(subject.current_day_index).to eq 0
    end

    context 'the current time is the next day' do
      let(:time_freeze) { tomorrow }

      it 'gets the index of the object representing the second day' do
        expect(subject.current_day_index).to eq 1
      end
    end
  end

  describe '#current_hourly_data' do
    it 'gets the hourly data for the current hour' do
      # the frozen time represents 1430, but we check for 730 to account for the time zone shift
      expect(subject.current_hourly_data).to be subject.data.days.first.hours[7]
      expect(subject.current_hourly_data.datetime).to eq "07:00:00"
    end
  end

  describe '#data' do
    it 'returns the top-level data' do
      expect(subject.data.tzoffset).to eq -7.0
    end

    it 'does not allow modifying the data' do
      expect {
        subject.data.tzoffset = 4
      }.to raise_error(FrozenError)
    end
  end

  describe '#local_time' do
    it 'adjusts the current system time to match the time zone of the forecast' do
      expect(subject.local_time.hour).to eq time_freeze.hour + subject.data.tzoffset
    end
  end
end
