require 'test_helper'

class ProductsControllerTest < ActionController::TestCase
  setup do
    @product = products(:one)
    @update = {
      title: 'Lorem Ipsum',
      description: 'Wibbles are fun!',
      image_url: 'lorem.jpg',
      price: 19.95
    }
    @ruby_product = products(:ruby)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:products)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create product" do
    assert_difference('Product.count') do
      post :create, product: @update
    end

    assert_redirected_to product_path(assigns(:product))
  end

  test "should show product" do
    get :show, id: @product
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @product
    assert_response :success
  end

  test "should update product" do
    put :update, id: @product, product: @update
    assert_redirected_to product_path(assigns(:product))
  end

  test "should destroy product" do
    assert_difference('Product.count', -1) do
      delete :destroy, id: @product
    end

    assert_redirected_to products_path
  end

  test "should receive atom feed for product" do
    get :who_bought, id: @ruby_product, format: "atom"
    assert_select "feed>entry" do
      assert_select "title", /Order \d/
      assert_select "summary>div>p:first-of-type", 
        /Shipped to MyAddress/
      assert_select "summary>div>table>tr:nth-of-type(2)>td:first-of-type",
        /Programming Ruby 1.9/
      assert_select "summary>div>p:last-of-type", /Paid by Check/
      assert_select "author>name", /Dave Thomas/
      assert_select "author>email", /dave@example.org/
    end
  end
end
