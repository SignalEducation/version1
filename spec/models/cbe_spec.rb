require 'rails_helper'

RSpec.describe Cbe, type: :model do

  context 'When creating an empty CBE' do
    it 'Should return nil values for name, title, description, and exam_body_id to be nil ' do
      cbe = Cbe.new
      expect(cbe.name).to eq nil
      expect(cbe.title).to eq nil
      expect(cbe.description).to eq nil
      expect(cbe.exam_body_id).to eq nil
    end
  end
  
  context 'When creating a CBE with values set' do
    it 'Should create a new CBE record with those values saved' do
      cbe = Cbe.create(name: 'BCCA EXAM', title: 'exam 1', description: 'test desc', exam_body_id: 1)
      expect(cbe.errors.blank?).to eq true
    end
  end

  context 'When creating a CBE with no alues set' do
    it 'Should return errors' do
      cbe = Cbe.create
      expect(cbe.errors.blank?).to eq false
    end
  end


end
