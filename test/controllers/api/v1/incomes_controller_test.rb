require "test_helper"

class Api::V1::IncomesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_v1_incomes_index_url
    assert_response :success
  end

  test "should get create" do
    get api_v1_incomes_create_url
    assert_response :success
  end

  test "should get update" do
    get api_v1_incomes_update_url
    assert_response :success
  end

  test "should get destroy" do
    get api_v1_incomes_destroy_url
    assert_response :success
  end
end
