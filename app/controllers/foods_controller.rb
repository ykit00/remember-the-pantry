class FoodsController < ApplicationController
  def index
    @foods = Food.all.includes(:food_category)
  end
  def show
    @food = Food.find(params[:id])
  end
  def new
    @food = Food.new
  end
  def create
    @food = Food.new(food_params)

    if @food.save
      redirect_to foods_path
    else
      render 'new'
    end
  end

  private
    def food_params
      params.require(:food).permit(:name)
    end
end
