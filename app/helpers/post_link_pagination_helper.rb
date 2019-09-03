# frozen_string_literal: true

module PostLinkPaginationHelper
  class LinkRenderer < WillPaginate::ActionView::LinkRenderer
    def link(text, target, _attributes = {})
      post_request_pagination(target, text)
    end

    def post_request_pagination(target, text)
      if target.is_a?(Integer)
        page = target
      else
        target = target.split('?')
        action = target.first
        params = target.drop(1).join
        page = CGI.parse(params)['page'].first
      end
      tag :form, input_tags(text, page).join, action: @options[:action] || action, method: :post
    end

    def input_tags(text, page)
      attributes = { type: :hidden }
      [
        tag(:button, text, type: :submit, class: 'btn btn-secondary'),
        tag(:input, nil, attributes.merge(name: :page, value: page)),
        tag(:input, nil, attributes.merge(name: :authenticity_token)),
        tag(:input, nil, attributes.merge(name: :will_paginate, value: true))
      ] << post_params
    end

    def post_params
      return unless @options[:post_params]
      @options[:post_params].map do |key, value|
        next if key.to_s == 'page'
        tag :input, nil, type: :hidden, name: key, value: value
      end
    end
  end
end
