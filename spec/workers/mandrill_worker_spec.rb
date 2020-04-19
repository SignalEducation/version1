# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe MandrillWorker do
  let(:message)         { build(:message) }
  let(:response_params) { [{"email"=>"test-user@example.com", "status"=>"sent", "_id"=>"123456789abcdefg", "reject_reason"=>nil}] }
  before do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
    allow_any_instance_of(MandrillClient).to receive(:send).and_return(response_params)
    allow(Message).to receive(:find).and_return(message)
  end

  after do
    Sidekiq::Worker.drain_all
  end

  subject { MandrillWorker }

  it 'Mandrill job is processed in high queue.' do
    expect { subject.perform_at(message.process_at, message.id) }.to change(subject.jobs, :size).by(1)
  end
end
