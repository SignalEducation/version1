# frozen_string_literal: true

require 'rails_helper'
require 'segment/analytics'

describe SegmentService, type: :service do

  # CUSTOMERS ==================================================================
  context 'users' do
    describe '#identify_user' do
      let(:user) { create(:user) }

      it 'creates the user on Segment' do
        SegmentService.new.identify_user(user)

        subject.identify_user(user)
      end

    end
  end

end
