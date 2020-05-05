# frozen_string_literal: true

require 'rails_helper'

describe PostLinkPaginationHelper::LinkRenderer, type: :helper do
  let(:link_renderer) { described_class.new }

  before do
    link_renderer.instance_variable_set(:@options, { action: nil, post_params: { first_param: 'first_value' } })
  end

  describe '#link' do
    context 'without page as param' do
      it 'cbe product' do
        allow_any_instance_of(described_class).to receive(:post_params).and_return({})
        link = link_renderer.link('Cbe Product', 'cbe_product')

        expect(link).to include('submit')
        expect(link).to include('cbe_product')
        expect(link).to include('will_paginate')
      end
    end

    context 'with page as param' do
      it 'cbe product' do
        allow_any_instance_of(described_class).to receive(:post_params).and_return({})
        link = link_renderer.link('Cbe Product', 1)

        expect(link).to include('submit')
        expect(link).to include('Cbe Product')
        expect(link).to include('will_paginate')
      end
    end

    context 'with post_params' do
      it 'cbe product' do
        link = link_renderer.link('Cbe Product', 1)

        expect(link).to include('submit')
        expect(link).to include('Cbe Product')
        expect(link).to include('will_paginate')
      end
    end
  end
end
