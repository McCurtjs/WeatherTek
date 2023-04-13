# The actual geocoder object is much more complex, but this covers the fields
# we're using for the purpose of specs
RSpec.shared_context 'geocoder_samples' do

  before do
    @geocoder_seattle = [OpenStruct.new({
      city: 'Seattle',
      postal_code: '98121',
    })]

    @geocoder_empire_state_building = [OpenStruct.new({
      city: 'New York',
      postal_code: '10118',
    })]

    @geocoder_potato_wharf = [OpenStruct.new({
      street: 'Potato Wharf',
      postal_code: 'M3 4',
      city: 'Manchester',
    })]

    @geocoder_blank = [OpenStruct.new({
      city: '',
      postal_code: '',
    })]

    @geocoder_seattle_no_post = [OpenStruct.new({
      city: 'seattle',
      postal_code: '',
    })]

    @geocoder_empty = []
  end

end
