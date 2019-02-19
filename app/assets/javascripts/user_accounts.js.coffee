$(document).on "ready page:load", ->

  $('#continue_cancelling_button').on 'click', (e) ->
    $('#cancellation_initiation').slideUp()
    $('#cancellation_completion').slideDown()

  $('#attempt_subscription_cancellation').on 'submit', (e) ->
    reason = $("input[name='subscription[cancellation_reason]']:checked").val()
    note = $("textarea[name='subscription[cancellation_note]'").val()
    if typeof reason isnt 'undefined'
      $('#cancellation-note-error').hide()
      $('.cancellation-reason').removeClass('error')
      if reason == 'Other' and (typeof note is 'undefined' or note == '')
        e.preventDefault()
        $('#cancellation-note-error').text("Please tell us why you're cancelling")
        $('#subscription_cancellation_note').addClass('error')
        $('#cancellation-reason-error').hide()
        $('#cancellation-note-error').show()
      else
        $('#subscription_cancellation_note').removeClass('error')
    else
      e.preventDefault()
      $('#cancellation-reason-error').text("Please tell us why you're cancelling")
      $('.cancellation-reason').addClass('error')
      $('#cancellation-reason-error').show()