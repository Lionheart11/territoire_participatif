require 'test_helper'

class ProjetsControllerTest < ActionController::TestCase

  def setup
    @contributeur = create(:contributeur)
    @categorie = create(:categorie)
    @projet = create(:projet,
                     contributeur: @contributeur,
                     categorie: @categorie)
  end

  test "lister les projets" do
    built_projets = create_list(:projet, 10)
    get :index
    assert_response :success
    assert_not_nil assigns(:projets)
    assert_equal 11, assigns(:projets).count
    assert assigns(:projets).first.updated_at > assigns(:projets).last.updated_at,
      "les projets ne sont pas classés par date de mise à jour décroissante"
    assert_template :index
  end

  test "afficher un projet" do
    get :show, id: @projet.id
    assert_not_nil assigns(:projet)
    assert_equal @projet.commentaires, assigns(:commentaires)
    assert_response :success
    assert_select 'h1', @projet.titre
    assert_select 'p', @projet.objectif
    assert_select 'p', @projet.description
  end

  test "ne peut pas accéder au formulaire d'un nouveau projet si pas connecté" do
    get :new
    assert_redirected_to new_contributeur_session_path
  end

  test "nouveau projet" do
    sign_in @contributeur
    get :new
    assert_response :success
    assert_not_nil assigns(:projet)
    assert_template :new
  end

  test "ne pas créer un projet sans contributeur connecté" do
    post :create, projet: {titre: 'MyString', objectif: 'MyString', description: 'MyText'}
    assert_redirected_to new_contributeur_session_path
  end

  test "créer un projet" do
    count = Projet.count
    sign_in @contributeur
    post :create, projet: attributes_for(:projet)
    assert_equal @projet.titre, assigns(:projet).titre
    assert_equal count + 1, Projet.count
    assert_equal @contributeur.id, assigns(:projet).contributeur_id, "le projet n'est pas associé au bon contributeur"
    assert_redirected_to projet_path assigns(:projet)
  end

  test "redirige vers new si projet invalide" do
    sign_in @contributeur
    projet_params = attributes_for(:projet)
    projet_params[:titre] = ''
    post :create, projet: projet_params
    assert_template :new
  end

  test "ne peux pas éditer un projet sans contributeur connecté" do
    get :edit, id: @projet.id
    assert_redirected_to new_contributeur_session_path
  end

  test "ne peux pas éditer un projet dont je ne suis pas l'auteur" do
    sign_in create(:contributeur)
    get :edit, id: @projet.id
    assert_response 403
  end

  test "editer un projet" do
    sign_in @contributeur
    get :edit, id: @projet.id
    assert_response :success
    assert_equal @projet, assigns(:projet)
  end

  test "ne peut pas mettre à jour un projet sans contributeur connecté" do
    patch :update, id: @projet.id, projet: {titre: 'YourString', objectif: 'MyString', description: 'MyString'}
    assert_redirected_to new_contributeur_session_path
  end

  test "ne peux pas mettre à jour un projet dont je ne suis pas l'auteur" do
    sign_in create(:contributeur)
    patch :update, id: @projet.id, projet: {titre: 'YourString', objectif: 'MyString', description: 'MyString'}
    assert_response 403
  end

  test "mettre à jour un projet" do
    sign_in @contributeur
    patch :update, id: @projet.id, projet: {titre: 'YourString', objectif: 'MyString', description: 'MyString'}
    assert_equal @projet, assigns(:projet)
    assert_equal 'YourString', assigns(:projet).titre
    assert_redirected_to projet_path assigns(:projet)
  end

  test "echec de mise à jour d'un projet invalide" do
    sign_in @contributeur
    projet_params = attributes_for(:projet)
    projet_params[:titre] = ''
    patch :update, id: @projet.id, projet: projet_params
    assert_template :edit
  end

end
