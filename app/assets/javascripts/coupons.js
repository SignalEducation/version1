$(document).on('ready', function () {
  $('#coupon_code').on('input', function (e) {
    validateCoupon();
  });

  // Hide green/red border and coupon error text if input has no value
  $('#coupon_code').blur(function () {
    if ($('#coupon_code').val() === '') {
      $('#coupon_code').removeClass("coupon-error");
      $('#coupon_code').removeClass("coupon-success");
      $('.invalid-code').hide();
    }
  });
});

// Trigger Ajax call on every input into the coupon field.
// Ajax call params are the coupon field value and selected_plan_id
// If response contains 'valid:true' add green border to field input
// If response contains 'valid:false' add red border to field and show error text
function validateCoupon() {
  const couponCode = $('#coupon_code');
  const planId = $("input[name='plans']:checked").val();

  if (couponCode.val() != "") {
    $.ajax({
      url: '/coupon_validation',

      dataType: 'json',
      method: 'POST',
      contentType: "application/json; charset=utf-8",
      data: JSON.stringify({
        'coupon_code': couponCode.val(),
        'plan_id': planId
      }),
      success: function (data) {
        const validCoupon = data.valid;

        if (validCoupon === false) {
          displayInvalidCouponClasses(data.reason);
        } else if (validCoupon === true) {
          displayValidCouponClasses(data.discounted_price);
        } else {
          removeCouponClasses();
        }

      },
      error: function (xhr, status, error) {
        console.log(xhr);
      }
    });
  }
}

function removeCouponClasses(){
   $('#coupon_code').removeClass("coupon-error");
   $('#coupon_code').removeClass("coupon-success");
   $('#coupon_code').hide();
}

function displayInvalidCouponClasses(reason) {
   $('#coupon_code').removeClass("coupon-success");
   $('#coupon_code').addClass("coupon-error");
   $('.invalid-code').show();
   $('.discounted-price').hide();
   $('#stripe-total-value').removeClass('strike');
   $('.invalid-code').text(reason);
}

function displayValidCouponClasses(discountedPrice) {
  $('#coupon_code').removeClass("coupon-error");
  $('#coupon_code').addClass("coupon-success");
  $('.invalid-code').hide();
  $('.discounted-price').show();
  $('#stripe-total-value').addClass('strike');
  $('#discounted-value').text(discountedPrice);
}
