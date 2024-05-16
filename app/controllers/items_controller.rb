class ItemsController < ApplicationController
  before_action :set_item, only: %i[show edit update destroy]

  def index
    @items = current_user.items.order(created_at: :desc)
  end

  def show; end

  def new
    @item = Item.new
  end

  def edit; end

  def create
    @item = Item.new(item_params)
    @item.user = current_user
    if @item.save
      flash[:success] = t('items.create.success')
      redirect_to items_url
    else
      flash.now[:danger] = t('items.create.failure')
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @item.update(item_params)
      flash[:success] = t('items.update.success')
      redirect_to item_url(@item)
    else
      flash.now[:danger] = t('items.update.failure')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    flash[:success] = t('items.destroy.success')
    redirect_to items_url
  end

  private

  def item_params
    params.require(:item).permit(:title, :description, :item_url)
  end

  def set_item
    @item = current_user.items.find(params[:id])
  end
end
