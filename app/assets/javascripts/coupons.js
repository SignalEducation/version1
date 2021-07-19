$(document).on('ready', function () {
  $('#coupon_code').on('focus', function (e) {
    couponFieldFocus(analyticsData);
  });

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
    couponFieldExit(analyticsData);
  });
});

// Trigger Ajax call on every input into the coupon field.
// Ajax call params are the coupon field value and selected_plan_id
// If response contains 'valid:true' add green border to field input
// If response contains 'valid:false' add red border to field and show error text
function validateCoupon() {
  const couponCode = $('#coupon_code');
  const planId = $("input[name='plans']:checked").val();

  if (couponCode.val() != "" && typeof planId !== 'undefined') {
    $.ajax({
      url: '/coupon_validation',

      dataType: 'json',
      method: 'POST',
      async: false,
      contentType: "application/json; charset=utf-8",
      data: JSON.stringify({
        'coupon_code': couponCode.val(),
        'plan_id': planId
      }),
      success: function (data) {
        const validCoupon = data.valid;

        if (validCoupon === false) {
          analyticsData.valid_coupon_present = false;
          analyticsData.discountedPrice =  '';
          analyticsData.couponCode = '';
          displayInvalidCouponClasses(data.reason);
        } else if (validCoupon === true) {
          analyticsData.valid_coupon_present = true;
          // regex to remove the currency iso code and let just the numbers.
          let discounted_price = Number(data.discounted_price.replace(/[^0-9\.-]+/g,""));
          analyticsData.discountedPrice = discounted_price.toString()  ;
          analyticsData.couponCode = couponCode.val();
          displayValidCouponClasses(data.discounted_price, data.coupon_id);
        } else {
          analyticsData.valid_coupon_present = false;
          analyticsData.discountedPrice =  '';
          analyticsData.couponCode = '';
          removeCouponClasses();
        }

      },
      error: function (xhr, status, error) {
        console.log(xhr);
      }
    });
  }

  if (typeof planId == 'undefined') {
    displayInvalidCouponClasses('You need to choose a plan to apply a coupon.');
  }
}

function removeCouponClasses(){
   $('#coupon_code').removeClass("coupon-error");
   $('#coupon_code').removeClass("coupon-success");
   $('#coupon_code').hide();
   $('#subscription_coupon_id').val('');
   $('#discounted_price').val('');
}

function displayInvalidCouponClasses(reason) {
   $('#coupon_code').removeClass("coupon-success");
   $('#coupon_code').addClass("coupon-error");
   $('.invalid-code').show();
   $('.discounted-price').hide();
   $('#stripe-total-value').removeClass('strike');
   $('.invalid-code').text(reason);
   $('#subscription_coupon_id').val('');
   $('#discounted_price').val('');
}

function displayValidCouponClasses(discountedPrice, coupon_id) {
  $('#coupon_code').removeClass("coupon-error");
  $('#coupon_code').addClass("coupon-success");
  $('.invalid-code').hide();
  $('.discounted-price').show();
  $('#stripe-total-value').addClass('strike');
  $('#discounted-value').text(discountedPrice);
  $('#subscription_coupon_id').val(coupon_id);
  $('#discounted_price').val(discountedPrice);
}
