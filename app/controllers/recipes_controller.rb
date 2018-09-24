class RecipesController < ApplicationController
  before_action :set_recipe, only: [:show, :edit, :update, :destroy, :used_as_ingredient]

  def index
    @recipes = Recipe.all
  end

  def show
    pantry_foods_id = current_user.my_pantry.map(&:food_id)
    @foods_in_pantry = @recipe.ingredients.select do |ingredient|
      pantry_foods_id.include?(ingredient.food_id)
    end
  end

  def new
    @recipe = Recipe.new
  end

  def edit
  end

  def create
    # TODO: レシピ作成未完成
    @recipe = current_user.recipes.build(recipe_params)
    food = Food.find_by(name: params[:recipe][:ingredient])
    @ingredient = @recipe.ingredients.new(food_id: food.id)


    if @recipe.save
      redirect_to @recipe, notice: 'Recipe was successfully created.' if @ingredient.save
    else
      render :new
    end
  end

  def update
    if @recipe.update(recipe_params)
      redirect_to @recipe, notice: 'Recipe was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @recipe.destroy
    redirect_to recipes_url, notice: 'Recipe was successfully destroyed.'
  end

  def can_be_made
    pantry_foods_id = current_user.my_pantry.map(&:food_id)
    recipes = Recipe.all

    @enable_recipes = recipes.includes(:ingredients).select do |recipe|
      recipe_foods_id = recipe.foods_id
      recipe_foods_id == recipe_foods_id & pantry_foods_id
    end
  end

  def a_little_more
    pantry_foods_id = current_user.my_pantry.map(&:food_id)
    recipes = Recipe.all

    @enable_recipes = recipes.includes(:ingredients).select do |recipe|
      recipe_foods_id = recipe.foods_id
      (recipe_foods_id & pantry_foods_id).length >= (recipe_foods_id.length / 2)
    end
  end

  def used_as_ingredient
    return redirect_to @recipe if (@recipe.foods_id & current_user.my_pantry_foods_id).empty?

    @recipe.foods_id.each do |food_id|
      remove_storage = current_user.my_pantry.find_by(food_id: food_id)
      remove_storage.destroy if remove_storage.present?
    end

    redirect_to (root_url)
  end

  private
    def set_recipe
      @recipe = Recipe.find(params[:id])
    end

    def recipe_params
      params.require(:recipe).permit(:name, ingredients_attributes: [:food])
    end
end
