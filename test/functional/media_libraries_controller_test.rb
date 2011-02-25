require 'test_helper'

class MediaLibrariesControllerTest < ActionController::TestCase
  setup do
    @media_library = media_libraries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:media_libraries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create media_library" do
    assert_difference('MediaLibrary.count') do
      post :create, :media_library => @media_library.attributes
    end

    assert_redirected_to media_library_path(assigns(:media_library))
  end

  test "should show media_library" do
    get :show, :id => @media_library.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @media_library.to_param
    assert_response :success
  end

  test "should update media_library" do
    put :update, :id => @media_library.to_param, :media_library => @media_library.attributes
    assert_redirected_to media_library_path(assigns(:media_library))
  end

  test "should destroy media_library" do
    assert_difference('MediaLibrary.count', -1) do
      delete :destroy, :id => @media_library.to_param
    end

    assert_redirected_to media_libraries_path
  end
end
