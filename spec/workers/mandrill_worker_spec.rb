# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe MandrillWorker do
  let(:message)         { create(:message) }
  let(:response_params) { [{"email"=>"test-user@example.com", "status"=>"sent", "_id"=>"123456789abcdefg", "reject_reason"=>nil}] }
  before :each do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
    allow(Message).to receive(:find).and_return(message)
  end

  after do
    Sidekiq::Worker.drain_all
  end

  subject { MandrillWorker }

  it 'Mandrill job is processed in high queue.' do
    allow_any_instance_of(MandrillClient).to receive(:send).and_return(response_params)
    expect { subject.perform_at(message.process_at, message.id) }.to change(subject.jobs, :size).by(1)
  end

  it 'calls #send_message' do
    expect_any_instance_of(MandrillWorker).to receive(:send_message)

    subject.new.perform(message.id)
  end

  describe '#send_message' do
    it 'calls the MandrillClient' do
      expect_any_instance_of(MandrillClient).to receive(:send).and_return(response_params)

      subject.new.send_message(message, 'send_set_password_email', 'url')
    end

    it 'updates the message' do
      allow_any_instance_of(MandrillClient).to receive(:send).and_return(response_params)
      expect(message).to receive(:update)

      subject.new.send_message(message, 'send_set_password_email', 'url')
    end
  end
end
