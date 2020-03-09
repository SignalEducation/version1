# frozen_string_literal: true

require 'rails_helper'

describe UsersCsvHelper, type: :helper do
  let(:user) { build(:user) }

  describe '#preview_csv_user_errors' do
    context 'valid user' do
      it 'pending exercise' do
        user.valid?
        expect(preview_csv_user_errors(user.errors)).to be_empty
      end
    end

    context 'invalid user' do
      it 'pending exercise' do
        user.email = nil
        user.valid?
        expect(preview_csv_user_errors(user.errors)).not_to be_empty
      end
    end
  end
end
