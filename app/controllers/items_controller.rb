class ItemsController < ApplicationController
  before_action :set_item, only: %i[show edit update destroy]

  def index
    @items = current_user.items.order(created_at: :desc).page(params[:page]).per(10)
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
      flash[:success] = 'アイテムを作成しました'
      redirect_to items_url
    else
      flash.now[:danger] = 'アイテムを作成できませんでした'
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @item.update(item_params)
      flash[:success] = 'アイテムを更新しました'
      redirect_to item_url(@item)
    else
      flash.now[:danger] = 'アイテムを更新できませんでした'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    flash[:success] = 'アイテムを削除しました'
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
