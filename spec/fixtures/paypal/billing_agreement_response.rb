{
  "name": "Override Agreement",
  "description": "Agreement that overrides merchant preferences and charge models",
  "payer": {
    "payment_method": "paypal",
    "payer_info": {
      "email": "payer@example.com"
    }
  },
  "plan": {
    "id": "P-1WJ68935LL406420PUTENA2I",
    "state": "ACTIVE",
    "name": "Fast Speed Plan",
    "description": "Vanilla plan",
    "type": "INFINITE",
    "payment_definitions": [
      {
        "id": "PD-9WG6983719571780GUTENA2I",
        "name": "Regular payment definition",
        "type": "REGULAR",
        "frequency": "DAY",
        "amount": {
          "currency": "GBP",
          "value": "10"
        },
        "charge_models": [
          {
            "id": "CHM-8373958130821962WUTENA2Q",
            "type": "SHIPPING",
            "amount": {
              "currency": "GBP",
              "value": "1"
            }
          },
          {
            "id": "CHM-2937144979861454NUTENA2Q",
            "type": "TAX",
            "amount": {
              "currency": "GBP",
              "value": "2"
            }
          }
        ],
        "cycles": "0",
        "frequency_interval": "1"
      },
      {
        "id": "PD-89M493313S710490TUTENA2Q",
        "name": "Trial payment definition",
        "type": "TRIAL",
        "frequency": "MONTH",
        "amount": {
          "currency": "GBP",
          "value": "100"
        },
        "charge_models": [
          {
            "id": "CHM-78K47820SS4923826UTENA2Q",
            "type": "SHIPPING",
            "amount": {
              "currency": "GBP",
              "value": "10"
            }
          },
          {
            "id": "CHM-9M366179U7339472RUTENA2Q",
            "type": "TAX",
            "amount": {
              "currency": "GBP",
              "value": "12"
            }
          }
        ],
        "cycles": "5",
        "frequency_interval": "2"
      }
    ],
    "merchant_preferences": {
      "setup_fee": {
        "currency": "GBP",
        "value": "3"
      },
      "max_fail_attempts": "11",
      "return_url": "https://example.com/",
      "cancel_url": "https://example.com/cancel",
      "auto_bill_amount": "YES",
      "initial_fail_amount_action": "CONTINUE"
    }
  },
  "links": [
    {
      "href": "https://api.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=EC-83C745436S346813F",
      "rel": "approval_url",
      "method": "REDIRECT"
    },
    {
      "href": "https://api.sandbox.paypal.com/v1/payments/billing-agreements/EC-83C745436S346813F/agreement-execute",
      "rel": "execute",
      "method": "POST"
    }
  ],
  "start_date": "2017-12-22T09:13:49Z"
}