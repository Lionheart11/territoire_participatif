require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  def setup
    @base_title = "Perchons"
  end

  test "should get mentions" do
    titre = "Mentions légales"
    get :mentions
    assert_response :success
    assert_select 'title', "#{titre} - #{@base_title}"
    assert_select 'h1', titre
  end

  test "la page charte existe" do
    titre = "Charte d'utilisation"
    get :charte
    assert_response :success
    assert_select 'title', "#{titre} - #{@base_title}"
    assert_select 'h1', titre
  end

  test "la page 'comment ça marche?' existe" do
    titre = "Comment ça marche ?"
    get :howto
    assert_response :success
    assert_select 'title', "#{titre} - #{@base_title}"
    assert_select 'h1', titre
  end

  test "un visiteur ne peux pas accéder à la page animation" do
    get :animation
    assert_redirected_to new_contributeur_session_path
  end

  test "un contributeur ne peux pas accéder à la page animation" do
    sign_in create(:contributeur)
    get :animation
    assert_response 403
  end

  test "un animateur peut accéder à la page animation" do
    sign_in create(:animateur)
    get :animation
    assert_response :success
    assert_select 'title', /Animation/
  end

end
