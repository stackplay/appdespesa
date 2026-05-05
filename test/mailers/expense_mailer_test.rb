require "test_helper"

class ExpenseMailerTest < ActionMailer::TestCase
  test "welcome_email" do
    mail = ExpenseMailer.welcome_email
    assert_equal "Welcome email", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "limit_warning" do
    mail = ExpenseMailer.limit_warning
    assert_equal "Limit warning", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "monthly_report" do
    mail = ExpenseMailer.monthly_report
    assert_equal "Monthly report", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
