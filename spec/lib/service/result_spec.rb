# frozen_string_literal: true

require 'service/result'

RSpec.describe Service::Result do
  subject(:result) { described_class.new(options) }

  describe 'initialisation' do
    context 'when a resource is given' do
      let(:options) do
        {
          resource: {
            id: 32,
            uid: 'jane.doe@gmail.com',
            email: 'jane.doe@gmail.com',
            name: 'Jane Doe',
            image_url: nil
          }
        }
      end

      it 'sets the resource if one is given' do
        expect(result.resource).to eq({
                                        id: 32,
                                        uid: 'jane.doe@gmail.com',
                                        email: 'jane.doe@gmail.com',
                                        name: 'Jane Doe',
                                        image_url: nil
                                      })
      end
    end

    context 'when no resource is given' do
      let(:options) { {} }

      it 'sets the resource to nil' do
        expect(result.resource).to be nil
      end
    end

    context 'when there are errors' do
      let(:options) do
        {
          errors: ['foo', ['bar', ['baz', 'qux']]]
        }
      end

      it 'sets the errors array to a flattened value' do
        expect(result.errors).to eq %w[foo bar baz qux]
      end
    end

    context 'when there is one error' do
      let(:options) do
        {
          error: 'foobar'
        }
      end

      it 'sets the errors to an array' do
        expect(result.errors).to eq %w[foobar]
      end
    end

    context 'when there are no errors' do
      let(:options) { {} }

      it 'sets the errors to an empty array' do
        expect(result.errors).to eq []
      end
    end
  end

  describe 'instance methods' do
    let(:options) { {} }

    describe '#success?' do
      it 'is false on the base class' do
        expect(result.success?).to be false
      end
    end

    describe '#failure?' do
      it 'is false on the base class' do
        expect(result.failure?).to be false
      end
    end

    describe '#ok?' do
      it 'is false on the base class' do
        expect(result.ok?).to be false
      end
    end

    describe '#created?' do
      it 'is false on the base class' do
        expect(result.created?).to be false
      end
    end

    describe '#no_content?' do
      it 'is false on the base class' do
        expect(result.no_content?).to be false
      end
    end

    describe '#unauthorized?' do
      it 'is false on the base class' do
        expect(result.unauthorized?).to be false
      end
    end

    describe '#not_found?' do
      it 'is false on the base class' do
        expect(result.not_found?).to be false
      end
    end

    describe '#method_not_allowed?' do
      it 'is false on the base class' do
        expect(result.method_not_allowed?).to be false
      end
    end

    describe '#unprocessable_entity?' do
      it 'is false on the base class' do
        expect(result.unprocessable_entity?).to be false
      end
    end
  end
end
