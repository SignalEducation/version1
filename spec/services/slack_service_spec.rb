# frozen_string_literal: true

require 'rails_helper'

describe SlackService, type: :service do
  describe '#notify_channel' do
    it 'calls #send_notification with a message hash' do
      expect(subject).to receive(:send_notification).with(hash_including(channel: '#test_channel'))

      subject.notify_channel('test_channel', {})
    end
  end

  describe '#order_summary_attachment' do
    before :each do
      create_list(:order, 3)
      @orders = Order.all
    end

    it 'returns an array with an attachment object' do
      expect(subject.order_summary_attachment(@orders)).to be_an(Array)
    end
  end

  describe 'private methods' do
    describe '#order_attachment' do
      before :each do
        create_list(:order, 3)
        @orders = Order.all
      end

      it 'returns an array with an attachment object' do
        expect(subject.send(:order_attachment, @orders)).to be_an(Array)
      end
    end

    describe '#slack_client' do
      it 'assigns a value to the @slack_client instance variable' do
        expect(subject.send(:slack_client)).to be_an_instance_of Slack::Web::Client
      end
    end

    describe '#send_notification' do
      it 'calls #chat_postMessage on the Slack Client' do
        expect_any_instance_of(Slack::Web::Client).to receive(:chat_postMessage).with(hash_including(channel: '#test_channel'))

        subject.send(:send_notification, { channel: '#test_channel' })
      end
    end
  end
end
