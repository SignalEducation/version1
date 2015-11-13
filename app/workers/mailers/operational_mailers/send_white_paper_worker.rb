class Mailers::OperationalMailers::SendWhitePaperWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'high'

  def perform(white_paper_request_id)
    request = WhitePaperRequest.where(id: white_paper_request_id).first
    white_paper = WhitePaper.where(id: request.white_paper_id).first
    file  = white_paper.file
    if request && white_paper
      OperationalMailer.send_white_paper(request, white_paper, file).deliver_now
    end
  end
end
