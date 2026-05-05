require "test_helper"

class Api::V1::StatsControllerTest < ActionDispatch::IntegrationTest
  test "should get overview" do
    get api_v1_stats_overview_url
    assert_response :success
  end

  test "should get monthly" do
    get api_v1_stats_monthly_url
    assert_response :success
  end

  test "should get by_category" do
    get api_v1_stats_by_category_url
    assert_response :success
  end
end
