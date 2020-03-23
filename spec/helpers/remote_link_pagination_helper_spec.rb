# frozen_string_literal: true

require 'rails_helper'

describe RemoteLinkPaginationHelper::LinkRenderer, type: :helper do
  let (:link_renderer) { described_class.new }

  describe '#link' do
    it 'remote link' do
      link = link_renderer.link('Cbe Product', 'cbe_product')

      expect(link).to include('data-remote')
      expect(link).to include('cbe_product')
      expect(link).to include('Cbe Product')
    end
  end
end
